#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
  dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='rh_white' \
model.templates=['/corticalflow/resources/neurips_templates/rh_white_template_30k.obj','/corticalflow/resources/neurips_templates/rh_white_template_135k.obj','/corticalflow/resources/neurips_templates/rh_white_template_450k.obj'] \
model.integration_method='Euler' \
outputs.output_dir=/corticalflow/output2/cf/out_rh_white

#trainer.resume='/data/users2/washbee/speedrun/corticalflow_fork/output2/cf/out_rh_white/checkpoints/model_DT1_ite070000.pth' \
