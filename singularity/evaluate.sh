#!/bin/bash -p
. /opt/miniconda3/bin/activate topofit
#enter the command you would like to run below or modify this script to be more dynamic
#eg. /topofit/evaluate ...
#eg. /topofit/train ... 
#eg. /topofit/preprocess ...
#the following example requires --bind yourtopofitclone:/topofit/
/topofit/evaluate --subjs /data/users2/washbee/hcp-plis-subj/358144 --hemi lh --model /data/users2/washbee/topofit/output/lh.1950.pt

/topofit/evaluate --subjs /data/users2/washbee/hcp-plis-subj/358144 --hemi rh --model /data/users2/washbee/topofit/output/rh.1850.pt

