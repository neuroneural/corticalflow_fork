#!/bin/bash
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --mem=30g
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:v100:1
#SBATCH -t 6999
#SBATCH -J wa-mutico
#SBATCH -e jobs/error%A.err
#SBATCH -o jobs/out%A.out
#SBATCH -A PSYC0002
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

singularity exec --nv --bind /data:/data/,/home:/home/,$HOME/projects/topofit:/topofit/,/data/users2/washbee/hcp-plis-subj/:/subj /data/users2/washbee/containers/topofitV1_release.sif /topofit/singularity_run/train.sh lh & 
p1 = $!

singularity exec --nv --bind /data:/data/,/home:/home/,$HOME/projects/topofit:/topofit/,/data/users2/washbee/hcp-plis-subj/:/subj /data/users2/washbee/containers/topofitV1_release.sif /topofit/singularity_run/train.sh rh &
p2 = $!

wait p1
wait p2

sleep 10s
