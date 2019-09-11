#!/bin/bash

# PBS directives
#PBS -N poly_corCAR1
#PBS -P cegs
#PBS -j oe
#PBS -o Logs/ultimate_QandD_poly_allReps_V3_corCAR1_correct.log
#PBS -l select=2:ncpus=8:mem=40GB
#PBS -l walltime=192:00:00

# WALLTIME #
# Script took about 112 hours on 2 nodes with 8 cores each
# but calculating emmeans failed
# emmeans calcualtion is fixed now and has been calculated separately in interactive session

module load R/3.4.0-foss-2016b

cd /lustre/scratch/users/pieter.clauw/UltimateQandD

#cp -v /net/gmi.oeaw.ac.at/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Growth/lemna_DAS_rep1_2_3_NO.txt Data/Growth/

Rscript --vanilla ${HOME}/Scripts/Growth/polynomialModel_clstr_V3_corCAR1.r


