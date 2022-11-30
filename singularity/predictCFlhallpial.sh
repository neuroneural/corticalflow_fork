#!/bin/bash
. /opt/miniconda3/bin/activate corticalflow
python /corticalflow/predict.py inputs.data_type=formatted \
inputs.path=/subj/ \
inputs.split_name=test \
inputs.split_file=/corticalflow/subjs.csv \
inputs.hemisphere='lh' \
inputs.device='cuda:0' \
inputs.template=/corticalflow/resources/neurips_templates/lh_pial_template_435k.stl \
white_model=null \
pial_model.integration_method='NeurIPS' \
pial_model.integration_steps=7 \
pial_model.share_flows=True \
pial_model.model_checkpoint=/corticalflow/resources/trained_models/CF_LEFT_PIAL.pth \
outputs.output_dir=/data/users2/washbee/corticalflow/output_lh_pial/ \

