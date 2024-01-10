#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
python /corticalflow/predict.py inputs.data_type=formatted \
inputs.path=/subj/ \
inputs.split_name=test \
inputs.split_file=/corticalflow/subjs.csv \
inputs.hemisphere='rh' \
inputs.device='cuda:0' \
inputs.template=/corticalflow/resources/neurips_templates/rh_white_template_450k.obj \
white_model.integration_method='Euler' \
white_model.integration_steps=30 \
white_model.share_flows=True \
white_model.model_checkpoint=/corticalflow/output2/cf/out_rh_white/best_model_DT2.pth \
pial_model=null \
outputs.output_dir=/corticalflow/output2/cf/out_rh_white/ \
