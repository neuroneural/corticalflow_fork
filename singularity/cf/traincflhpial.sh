#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train.py dataset.path=/subj/ \
dataset.split_file=/corticalflow/subjs.csv \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name='lh_pial' \
model.templates=['/corticalflow/resources/neurips_templates/lh_pial_template_30k.stl','/corticalflow/resources/neurips_templates/lh_pial_template_135k.stl','/corticalflow/resources/neurips_templates/lh_pial_template_435k.stl'] \
model.integration_method='Euler' \
outputs.output_dir=/corticalflow/output2/cf/out_lh_pial
