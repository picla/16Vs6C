#!/usr/bin/env bash

#SBATCH --time=336:00:00
#SBATCH --output Logs/ultimate_QandD_poly_allReps_V3_corCAR1_correct.log
#SBATCH --mem=40GB
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8


module load r/3.5.1-foss-2018b

Rscript --vanilla ${HOME}/Scripts/Growth/polynomialModel_clstr_V3_corCAR1.r


