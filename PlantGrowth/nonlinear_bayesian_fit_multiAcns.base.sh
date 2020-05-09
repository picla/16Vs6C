#!/usr/bin/env bash                                                                                                                                         

#SBATCH --time=7-00:00:00
#SBATCH --output Logs/nonlinear_bayesian_fit_multiAcns_%A_%a.log
#SBATCH --mem=120GB
#SBATCH --cpus-per-task=4
#SBATCH --qos=long
#SBATCH --array=0-1

# setup #
ml build-env/f2020
module load r/3.6.0-foss-2019a

# parameters
i=$SLURM_ARRAY_TASK_ID
temperatures=(16C 6C)
temp=${temperatures[$i]}

# run #
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/nonlinear_bayesian_fit_multiAcns.base.r $temp

