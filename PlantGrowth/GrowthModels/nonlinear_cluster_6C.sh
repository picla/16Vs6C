#!/usr/bin/env bash                                                                                                                                         

#SBATCH --time=30:00:00
#SBATCH --output Logs/nonlinear_cluster_6C.log
#SBATCH --mem=60GB
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --qos=long

# setup #
module load r/3.5.1-foss-2018b

# run #
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/GrowthModels/nonlinear_cluster_6C.r


