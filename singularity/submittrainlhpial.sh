#!/bin/bash
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --mem=30g
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:V100:1
#SBATCH --nodelist=arctrddgx001
#SBATCH -t 1-00:00
#SBATCH -J cflhpi
#SBATCH -e /data/users2/washbee/cfpp/jobs/error%A.err
#SBATCH -o /data/users2/washbee/cfpp/jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe


sleep 5s

module load singularity/3.10.2

export HYDRA_FULL_ERROR=1
singularity exec --nv --bind $HOME/projects/corticalflow:/corticalflow,/data,/data/users2/washbee/outdir:/subj,/data/users2/washbee/corticalflow_fork:/cf_fork /data/users2/washbee/containers/corticalflow3.sif /cf_fork/singularity/trainlhpial.sh &

wait

sleep 10s
