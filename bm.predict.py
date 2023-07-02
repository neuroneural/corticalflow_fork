from omegaconf import DictConfig, OmegaConf
import hydra, logging, os
import torch
import torch.nn.functional as tnnf
from torchvision.transforms import Compose
from torch.utils.data import DataLoader
from src.utils import TicToc, DatasetWrapper, export_mesh
from src.data import NormalizeMRIVoxels, InvertAffine, collate_CSRData_fn, csr_dataset_factory
from src.models import CorticalFlow, load_checkpoint
import pandas as pd
import numpy as np
import nibabel as nib
import trimesh
import datetime
import nvidia_smi
import socket

import time
import pynvml

import hashlib

from csv import writer

import subprocess

# Define the Bash command you want to run
command = "ls /data/users2/washbee/speedrun/topofit-data"

# Run the command and capture its output
output = subprocess.check_output(command, shell=True, universal_newlines=True)

print('ls ', output)

file_handle = None  # Global variable to store the file object
hostname = socket.gethostname()


def get_data_hash(data):
    # Convert data to a serialized string representation
    tensor_bytes = data.numpy().tobytes()

    # Compute the hash value of the serialized string
    hash_object = hashlib.sha256(tensor_bytes)
    data_hash = hash_object.hexdigest()

    return data_hash



def open_file(filename):
    global file_handle
    file_handle = open(filename, 'w')  # Open the file in read mode


def close_file():
    global file_handle
    if file_handle:
        file_handle.close()
        file_handle = None
        print("File closed.")
    else:
        print("No file is open.")


def write_time2csv(model_name, t_sec, hash_subj_id, loading=False):
    List = [model_name, t_sec,hostname, hash_subj_id]
    print(t_sec)
    filename = '/data/users2/washbee/speedrun/bm.events.csv'
    if loading is True:
        filename = '/data/users2/washbee/speedrun/bm.loading.csv'
    
        
    with open(filename, 'a') as f_object:
        writer_object = writer(f_object)
        writer_object.writerow(List)
        f_object.flush()
        #f_object.close()

nvidia_smi.nvmlInit()

deviceCount = nvidia_smi.nvmlDeviceGetCount()


# Helper functions
def printModelSize(model):
    # print(dir(model))
    param_size = 0
    for param in model.parameters():
        param_size += param.nelement() * param.element_size()
    buffer_size = 0
    for buffer in model.buffers():
        buffer_size += buffer.nelement() * buffer.element_size()
    size_all_mb = (param_size + buffer_size) / 1024**2
    print('\n\n\n\n')
    print('model size: {:.3f}MB'.format(size_all_mb))
    print('\n\n\n\n')


def printSpaceUsage():
    nvidia_smi.nvmlInit()
    msgs = ""
    for i in range(deviceCount):
        handle = nvidia_smi.nvmlDeviceGetHandleByIndex(i)
        info = nvidia_smi.nvmlDeviceGetMemoryInfo(handle)
        #print("Device {}: {}, Memory : ({:.2f}% free): {}(total), {} (free), {} (used)".format(i, nvidia_smi.nvmlDeviceGetName(handle), 100*info.free/info.total, info.total, info.free, info.used))
        msgs += '\n'
        msgs += "Device {}: {}, Memory : ({:.2f}% free): {}(total), {} (free), {} (used)".format(i, nvidia_smi.nvmlDeviceGetName(handle), 100*info.free/info.total, info.total, info.free, info.used)
        nvidia_smi.nvmlShutdown()
    msgs+="\nMax Memory occupied by tensors: "+ str(torch.cuda.max_memory_allocated(device=None))
    msgs+="\nMax Memory Cached: "+ str(torch.cuda.max_memory_cached(device=None))
    msgs+="\nCurrent Memory occupied by tensors: "+ str(torch.cuda.memory_allocated(device=None))
    msgs+="\nCurrent Memory cached occupied by tensors: "+str(torch.cuda.memory_cached(device=None))
    msgs+="\n"
    return msgs
    
# A logger for this file
logger = logging.getLogger(__name__)


@hydra.main(config_path="configs", config_name='predict')
def predict_app(cfg):

    a = datetime.datetime.now()

    # log for GPU utilization
    GPU_msgs = []

    ### Set Stage
    stage = '0 - override config' 
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')

    # override configuration with a user defined config file
    if cfg.user_config is not None:
        user_config = OmegaConf.load(cfg.user_config)
        cfg = OmegaConf.merge(cfg, user_config)
    logger.info('Predicting surfaces with Cortical Flow\nConfig:\n{}'.format(OmegaConf.to_yaml(cfg)))


    # timer
    timer = TicToc(); timer_dict = {}; timer.tic('Total')

    ### Set Stage
    stage = '0 - read MRI'
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')
    
    # read MRI
    timer.tic('ReadData')
    field_transforms = {'mri': Compose([NormalizeMRIVoxels('mean_std'), InvertAffine('mri_affine')])}          
    test_dataset = None
    if cfg.inputs.data_type == 'formatted':
        logger.info('loading from formatted dataset...')
        test_dataset = csr_dataset_factory('formatted', cfg.inputs.hemisphere, field_transforms, 
            dataset_path=cfg.inputs.path, split_file=cfg.inputs.split_file, split_name=cfg.inputs.split_name, surface_name=None)

    elif cfg.inputs.data_type == 'file':
        logger.info('loading from file...')
        test_dataset = csr_dataset_factory('file', cfg.inputs.hemisphere, field_transforms, input_file=cfg.inputs.path)

    elif cfg.inputs.data_type == 'list':
        logger.info('loading from list...')
        test_dataset = csr_dataset_factory('list', cfg.inputs.hemisphere, field_transforms, subjects=[cfg.inputs.split_name], mris=[cfg.inputs.path], surfaces=None)

    else:
        raise ValueError("Data format is not supported")
    test_dataloader = DataLoader(test_dataset, batch_size=1, collate_fn=collate_CSRData_fn, shuffle=False)   
    timer_dict['ReadData'] = timer.toc('ReadData')
    logger.info("{} subjects loaded for test in {:.4f} secs".format(len(test_dataset), timer_dict['ReadData']))
    
    ### Set Stage
    stage = '0 - load template mesh'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')

    # load template mesh
    template_mesh = trimesh.load(cfg.inputs.template)
    logger.info("Template mesh {} read from {}".format(template_mesh, cfg.inputs.template))


    ### Set Stage
    stage = '0 - setup white model'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')


    # setup white model
    white_model = None
    if cfg.white_model is not None:
        timer.tic('WhiteModelSetup')

        torch.cuda.empty_cache()
        print('\n*********empty cache, before loading white model() \n', printSpaceUsage())
        
        white_model = CorticalFlow(cfg.white_model.share_flows, cfg.white_model.nb_features, cfg.white_model.integration_method, cfg.white_model.integration_steps).to(cfg.inputs.device)
        print('\n*********after loading white model() \n', printSpaceUsage())


        white_model.eval()    
        timer_dict['WhiteModelSetup'] = timer.toc('WhiteModelSetup')
        logger.info("{:.4f} secs for white model setup:\n{}".format(timer_dict['WhiteModelSetup'], white_model))        
        model_num_params = sum(p.numel() for p in white_model.parameters())    
        logger.info('White model Total number of parameters: {}'.format(model_num_params))
    
        # load white model weights    
        timer.tic('WhiteModelLoadWeights')
    
        best_df, best_ite, best_val_loss = load_checkpoint(cfg.white_model.model_checkpoint, model=white_model)
        assert len(white_model.deform_blocks) == best_df + 1, "White Model seem not have trained all deformation blocks" 
        white_model_use_deforms = list(range(len(white_model.deform_blocks)))
        
        timer_dict['WhiteModelLoadWeights'] = timer.toc('WhiteModelLoadWeights')
        logger.info("White Model weights at deformation train {} iteration {} and validation metric {:.4f} loaded from {} in {:.4f} secs".format(
            best_df, best_ite, best_val_loss, cfg.white_model.model_checkpoint, timer_dict['WhiteModelLoadWeights']))
    else:
        logger.info("White model is not specified.")
    

    ### Set Stage
    stage = '0 - print white model size'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')

    # Print white model size
    print('white model size')
    printModelSize(white_model)    

    ### Set Stage
    stage = '0 - setup pial model'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')


    # setup pial model 
    pial_model = None
    if cfg.pial_model is not None:
        timer.tic('PialModelSetup')
        torch.cuda.empty_cache()
        print('\n*********empty cache, before loading pial model() \n', printSpaceUsage())
        pial_model = CorticalFlow(cfg.pial_model.share_flows, cfg.pial_model.nb_features, cfg.pial_model.integration_method, cfg.pial_model.integration_steps).to(cfg.inputs.device)
        #print(cfg.inputs.device)
        print('\n*********after loading pial model() \n', printSpaceUsage())

        pial_model.eval()    

        timer_dict['PialModelSetup'] = timer.toc('PialModelSetup')
        logger.info("{:.4f} secs for white model setup:\n{}".format(timer_dict['PialModelSetup'], pial_model))        
        model_num_params = sum(p.numel() for p in pial_model.parameters())    
        logger.info('Pial model Total number of parameters: {}'.format(model_num_params))
    
        # load pial model weights    
        timer.tic('PialModelLoadWeights')
        best_df, best_ite, best_val_loss = load_checkpoint(cfg.pial_model.model_checkpoint, model=pial_model)
        assert len(pial_model.deform_blocks) == best_df + 1, "Pial Model seem not have trained all deformation blocks" 
        pial_model_use_deforms = list(range(len(pial_model.deform_blocks)))
        timer_dict['PialModelLoadWeights'] = timer.toc('PialModelLoadWeights')
        logger.info("Pial Model weights at deformation train {} iteration {} and validation metric {:.4f} loaded from {} in {:.4f} secs".format(
            best_df, best_ite, best_val_loss, cfg.pial_model.model_checkpoint, timer_dict['PialModelLoadWeights']))
    else:
        logger.info("Pial model is not specified.")

    assert white_model is not None or pial_model is not None, "At least on of white or pial needs to be configured"

    ### Set Stage
    stage = '0 - print print pial model size'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')


    # Print pial model size
    print('pial model size')
    printModelSize(pial_model)

    ### Set Stage
    stage = '0 - End'
    #print(stage, printSpaceUsage())
    msgs = printSpaceUsage()
    GPU_msgs.append(stage + msgs + '\n\n\n')

    
    # Print GPU msgs
    for msg in GPU_msgs:
        print(msg)

    # network forward  and save results   
    logger.info("predicting...")
    os.makedirs(cfg.outputs.output_dir, exist_ok=True)
    count = 0
    b = datetime.datetime.now()
    t_sec = (b-a).total_seconds()
    write_time2csv('CorticalFlow', t_sec, "", loading=True)

    with torch.no_grad():                
        for ite, data in enumerate(test_dataloader):
            a = datetime.datetime.now()
            #print('ite',ite)
            #print('data',data)
            #print('ite.shape',ite.shape)
            #print('data.shape',data.shape)
            #print('c')
            # Check space usage 
            ### Set Stage
            stage = '0 - read batch data'
            msgs = printSpaceUsage()
            GPU_msgs.append(stage + msgs + '\n\n\n')

            #print('d')
            # read batch data               
            mri_vox = data.get('mri_vox').to(cfg.inputs.device)            
            mri_affine = data.get('mri_affine').to(cfg.inputs.device)             
            subject_ids = data.get('subject')              

            ### Set Stage
            stage = '0 - templates reinstate'
            msgs = printSpaceUsage()
            GPU_msgs.append(stage + msgs + '\n\n\n')


            # reinstate template for safety
            template_verts = torch.from_numpy(template_mesh.vertices).unsqueeze(0).repeat(mri_vox.shape[0], 1, 1).float().to(cfg.inputs.device) 
            template_faces  = torch.from_numpy(template_mesh.faces).unsqueeze(0).repeat(mri_vox.shape[0], 1, 1).int().to(cfg.inputs.device) 


            ### Set Stage
            stage = '0 - network prediction'
            msgs = printSpaceUsage()
            GPU_msgs.append(stage + msgs + '\n\n\n')


            # network prediction
            print('\n*********before white model() \n', printSpaceUsage())
            torch.cuda.empty_cache()
            print('\n*********emptying cache , before white model() \n', printSpaceUsage())
            if white_model is not None:
        
                _, _, _, pred_verts_white = white_model(mri_vox, mri_affine, template_verts, white_model_use_deforms); 
            print('\n*********after white model()…. \n', printSpaceUsage())

            print('\n*********before pial model() \n', printSpaceUsage())
            torch.cuda.empty_cache()
            print('\n*********emptying cache , before pial model() \n', printSpaceUsage())
            if pial_model is not None:
                print('Checked. Pial Model is not None. We have Pial Model.')
                _, _, _, pred_verts_pial = pial_model(mri_vox, mri_affine, 
                     pred_verts_white[-1] if white_model is not None else template_verts, pial_model_use_deforms)
                
            print('\n*********after pial model() \n', printSpaceUsage())

            
            ### Set Stage
            stage = '0 - save outputs'
            msgs = printSpaceUsage()
            GPU_msgs.append(stage + msgs + '\n\n\n')


            # save outputs                    
            for surface, pred_verts in [('white', pred_verts_white if white_model is not None else None), ('pial', pred_verts_pial if pial_model is not None else None)]:
                if pred_verts is not None:
                    pred_verts = [verts_batches.cpu().numpy() for verts_batches in pred_verts]
                    for d in range(len(pred_verts)):
                        if d in cfg.outputs.out_deform:
                            for b in range(pred_verts[d].shape[0]):
                                subject_dir = os.path.join(str(cfg.outputs.output_dir), str(subject_ids[b]))
                                os.makedirs(subject_dir, exist_ok=True)
                                mesh_output_filename_noext = os.path.join(str(subject_dir), "{}_{}_{}_Df{}".format(str(subject_ids[b]), cfg.inputs.hemisphere, surface, d))                                
                                export_mesh(pred_verts[d][b], template_mesh.faces, mesh_output_filename_noext, cfg.outputs.out_format, surface)                                
            

            ### Set Stage
            stage = '0 - End'
            #hash_subj_id = get_data_hash(data)

            msgs = printSpaceUsage()
            GPU_msgs.append(stage + msgs + '\n\n\n')


            b = datetime.datetime.now()
            t_sec = (b-a).total_seconds()
            write_time2csv('CorticalFlow', t_sec, str(subject_ids))
            logger.info("{} total seconds for batch.".format(t_sec))
            
            # Check space usage 
            #print('g')
            printSpaceUsage()

            #exit()
            # log progress
            count += len(subject_ids)
            if ite % 10 == 0:
                logger.info("{}/{} subjects processed.".format(count, len(test_dataset)))
            

    logger.info("DONE !!!".format(count, len(test_dataset)))            

# Shut down nivida_smi
#nvidia_smi.nvmlShutdown()
#exit()            

if __name__ == "__main__":
    predict_app()
