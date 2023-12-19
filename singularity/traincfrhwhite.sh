#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
  dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='rh_white' \
model.templates=['/corticalflow/resources/smooth_templates/rh_white_smooth_40k.obj','/corticalflow/resources/smooth_templates/rh_white_smooth_140k.obj','/corticalflow/resources/smooth_templates/rh_white_smooth_380k.obj'] \
outputs.output_dir=/corticalflow/output2/cf/out_rh_white
