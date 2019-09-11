#!/usr/bin/env bash

#SBATCH --time=14-00:00:00
#SBATCH --output Logs/ultimate_QandD_poly_allReps_V3_corCAR1_correct.log
#SBATCH --mem=40GB
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --qos=long

module load openmpi/3.1.1-gcc-7.3.0-2.30
module load r/3.5.1-foss-2018b

Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/polynomialModel_clstr_V3_corCAR1.r


