#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=30g
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:V100:1
#SBATCH -t 3-00:00
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe
#SBATCH --exclude=arctrdgn002
#SBATCH -J corticalfr
#SBATCH -e /data/users2/washbee/corticalflow/jobs/error%A.err
#SBATCH -o /data/users2/washbee/corticalflow/jobs/out%A.out

sleep 5s

module load singularity/3.10.2

singularity exec --nv --bind /data/users2/washbee/speedrun/corticalflow_fork:/corticalflow,/data:/data,/data/users2/washbee/outdir:/subj /data/users2/washbee/containers/speedrun/cfpp_sr.sif /corticalflow/singularity/trainrhwhite.sh &

wait

sleep 10s
