#!/bin/bash
#SBATCH -c 4
#SBATCH --mem=30g
#SBATCH -p qTRDGPU
#SBATCH --gres=gpu:RTX:1
#SBATCH -t 1-00:00
#SBATCH -J cfpredlh
#SBATCH -e jobs/error%A.err
#SBATCH -o jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe
#SBATCH --exclude=arctrdgn002,arctrddgx001

sleep 5s

source /usr/share/lmod/lmod/init/bash
module use /application/ubuntumodules/localmodules
module load singularity/3.10.2
singularity exec --nv --bind /data,/data/users2/washbee/speedrun/corticalflow_fork:/corticalflow,/data/users2/washbee/speedrun/deepcsr-preprocessed:/subj /data/users2/washbee/containers/speedrun/cfpp_bm2_sandbox/ /corticalflow/singularity/benchmarks/bm.predictlhall.sh &

wait

sleep 10s
