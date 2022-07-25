#!/bin/bash
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --mem=30g
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:v100:1
#SBATCH --nodelist=trendsdgx003.rs.gsu.edu 
#SBATCH -t 3-00:00
#SBATCH -J corticalflow
#SBATCH -e /data/users2/washbee/corticalflow/jobs/error%A.err
#SBATCH -o /data/users2/washbee/corticalflow/jobs/out%A.out
#SBATCH -A PSYC0002
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

singularity exec --nv --bind $HOME/projects/corticalflow:/corticalflow,/data:/data,/data/users2/washbee/outdir:/subj /data/users2/washbee/containers/corticalflow3.sif /corticalflow/singularity/trainlhwhite.sh &

wait

sleep 10s
