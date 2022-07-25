# Preprocessing
preprocessing is similar to deepcsr except the implicit representations are not necessary. One could optimize the proprocessing by updating this for corticalflow and corticalflow++, but this has not been done yet. 

See the following for preprocessing:  
              https://github.com/neuroneural/DeepCSR-fork/blob/master/singularity/readme.md
# Training 
The training parameters are overridden in the trainlhwhite.sh or trainrhwhite.sh files. The default parameters are in ../configs/train.yaml file. If not in overridden, the defaults are used. 

to run training on slurm use:  
      sbatch submittrainlhwhite.sh  
and  
                 sbatch submittrainrhwhite.sh  

you could either duplicate this script for pial surfaces or use corticalflow++ method, which requires a white surface to exist to deform that surface to pial. 
## To be continued for training 
We plan to implement the corticalflow++ method for generating pial surfaces shortly then integrate these models into nobrainer.

