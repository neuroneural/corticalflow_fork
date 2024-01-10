#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
#source $FREESURFER_HOME/SetUpFreeSurfer.sh 
python /corticalflow/train_pial.py dataset.path='/subj/' \
dataset.split_file='/corticalflow/subjs.csv' \
dataset.train_split_name=train \
dataset.val_split_name=val \
dataset.surface_name="lh_pial" \
outputs.output_dir="/corticalflow/output2/cfpp/out_lh_pial" \
white_model.model_checkpoint="/corticalflow/output2/cfpp/out_lh_white/best_model_DT2.pth" \
white_model.template="/corticalflow/resources/smooth_templates/lh_white_smooth_380k.obj"
