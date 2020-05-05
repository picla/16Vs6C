#!/usr/bin/env bash                                                                                                                                         

#SBATCH --time=2-00:00:00
#SBATCH --output Logs/nonlinear_bayesian_fit_16C_acns.e.log
#SBATCH --mem=50GB
#SBATCH --cpus-per-task=4
#SBATCH --qos=medium

# setup #
ml build-env/f2020
module load r/3.6.0-foss-2019a

# run #
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/nonlinear_bayesian_fit_16C_acns.e.r

