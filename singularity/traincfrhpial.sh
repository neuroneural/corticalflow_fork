#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='rh_pial' \
model.templates=['/corticalflow/resources/neurips_templates/rh_pial_template_30k.obj','/corticalflow/resources/neurips_templates/rh_pial_template_135k.obj','/corticalflow/resources/neurips_templates/rh_pial_template_435k.obj'] \
model.integration_method='NeurIPS' \
outputs.output_dir=/corticalflow/output2/cf/out_rh_pial
