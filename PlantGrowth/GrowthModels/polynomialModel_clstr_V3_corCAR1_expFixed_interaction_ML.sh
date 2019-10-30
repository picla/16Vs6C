#!/usr/bin/env bash

#SBATCH --time=9-00:00:00
#SBATCH --output Logs/ultimate_QandD_poly_allReps_V3_corCAR1_expFixed_interaction_ML.log
#SBATCH --mem=160GB                                                                                                  
#SBATCH --cpus-per-task=32
#SBATCH --qos=long

module load openmpi/3.1.1-gcc-7.3.0-2.30
module load r/3.5.1-foss-2018b

Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/polynomialModel_clstr_V3_corCAR1_expFixed_interaction_ML.r


