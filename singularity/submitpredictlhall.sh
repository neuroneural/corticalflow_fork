#!/bin/bash
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mem=30g
#SBATCH -p qTRDGPUH
#SBATCH --gres=gpu:V100:1
#SBATCH -t 1-00:00
#SBATCH -J cfpredlh
#SBATCH -e /data/users2/washbee/corticalflow/cfpp/jobs/error%A.err
#SBATCH -o /data/users2/washbee/corticalflow/cfpp/jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe
#SBATCH --exclude=arctrdgn002,arctrddgx001

sleep 5s

source /usr/share/lmod/lmod/init/bash
module use /application/ubuntumodules/localmodules
module load singularity/3.10.2
singularity exec --nv --bind /data/users2/washbee/speedrun/corticalflow_fork:/corticalflow,/data,/data/users2/washbee/outdir:/subj /data/users2/washbee/containers/speedrun/cfpp_sr.sif /corticalflow/singularity/predictlhall.sh &

wait

sleep 10s
