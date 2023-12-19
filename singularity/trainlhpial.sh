#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train_pial.py dataset.path='/subj/' \
dataset.split_file='/corticalflow/subjs.csv' \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name="'lh_pial'" \
outputs.output_dir="/corticalflow/output_dir_lh_pial_shortenedepochs" \
white_model.model_checkpoint="/corticalflow/output_dir_lh_white/best_model_DT2.pth" \
white_model.template="/corticalflow/resources/smooth_templates/lh_white_smooth_380k.obj" \
pial_model.number_of_iterations="[5000,5000,5000]"
