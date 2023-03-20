#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#export PYTHONPATH=/corticalflow/external/mesh_contains/ 
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/predict.py inputs.data_type=formatted \
inputs.path=/subj/ \
inputs.split_name=test \
inputs.split_file=/corticalflow/subjs.csv \
inputs.hemisphere='lh' \
inputs.device='cuda:0' \
inputs.template=/corticalflow/resources/neurips_templates/lh_white_template_435k.obj \
white_model.integration_method='RK4' \
white_model.integration_steps=30 \
white_model.share_flows=True \
white_model.model_checkpoint=/data/users2/washbee/speedrun/corticalflow_fork/output_dir_lh_white/best_model_DT2.pth \
pial_model=null \
outputs.output_dir=/corticalflow/output_lh_white_timing/ \

