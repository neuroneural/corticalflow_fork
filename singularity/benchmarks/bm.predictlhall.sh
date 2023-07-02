#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
export PYTHONPATH=/corticalflow/external/mesh_contains/ 
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/bm.predict.py inputs.data_type=formatted \
inputs.path=/subj/ \
inputs.split_name=test \
inputs.split_file=/corticalflow/bm.csv \
inputs.hemisphere='lh' \
inputs.device='cuda:0' \
inputs.template=/corticalflow/resources/smooth_templates/lh_white_smooth_380k.obj \
white_model.nb_features="[[[16,32,32,32],[32,32,32,32,32,16,16]],[[16,32],[32,32,16,16]],[[16,32],[32,32,16,16]]]" \
white_model.integration_method='RK4' \
white_model.integration_steps="30" \
white_model.share_flows=True \
white_model.model_checkpoint=/corticalflow/output_dir_lh_white/best_model_DT2.pth \
pial_model.nb_features="[[[16,32],[32,32,16,16]],[[16,32],[32,32,16,16]],[[16,32],[32,32,16,16]]]" \
pial_model.integration_method='RK4' \
pial_model.integration_steps=30 \
pial_model.share_flows=True \
pial_model.model_checkpoint=/corticalflow/output_dir_lh_pial_shortenedepochs/best_model_DT2.pth \
outputs.output_dir=/corticalflow/output_lh_hcptrained_benchmarks/ \
outputs.out_deform=[0,1,2] \
outputs.out_format=freesurfer \

