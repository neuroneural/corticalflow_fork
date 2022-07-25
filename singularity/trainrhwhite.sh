#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
export PYTHONPATH=/corticalflow/external/mesh_contains/ 
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
  dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='rh_white' \
model.templates=['/corticalflow/resources/smooth_templates/lh_white_smooth_40k.obj','/corticalflow/resources/smooth_templates/lh_white_smooth_140k.obj','/corticalflow/resources/smooth_templates/lh_white_smooth_380k.obj'] \
outputs.output_dir=/data/users2/washbee/corticalflow/ouput_dir_rh_white
