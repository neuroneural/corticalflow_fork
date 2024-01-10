#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='lh_white' \
model.templates=['/corticalflow/resources/neurips_templates/lh_white_template_30k.obj','/corticalflow/resources/neurips_templates/lh_white_template_135k.obj','/corticalflow/resources/neurips_templates/lh_white_template_435k.obj'] \
model.integration_method='NeurIPS' \
outputs.output_dir=/corticalflow/output2/cf/out_lh_white
