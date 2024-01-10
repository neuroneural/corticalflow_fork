#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#export PYTHONPATH=/corticalflow/external/mesh_contains/ 
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/predict.py inputs.data_type=formatted \
inputs.path=/subj/ \
inputs.split_name=test \
inputs.split_file=/corticalflow/subjs.csv \
inputs.hemisphere='rh' \
inputs.device='cuda:0' \
inputs.template=/corticalflow/resources/neurips_templates/rh_pial_template_435k.obj \
white_model=null \
pial_model.nb_features='[[[16,32,32,32],[32,32,32,32,32,16,16]],[[16,32],[32,32,16,16]],[[16,32],[32,32,16,16]]]' \
pial_model.integration_method='NeurIPS' \
pial_model.integration_steps=7 \
pial_model.share_flows=True \
pial_model.model_checkpoint=/corticalflow/resources/trained_models/CF_RIGHT_PIAL.pth \
outputs.output_dir=/data/users2/washbee/corticalflow/output_rh_pial/ \

