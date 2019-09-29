#!/usr/bin/env bash

# SLURM
#SBATCH--mem=20GB
#SBATCH --output=Logs/rosette35DAS_LGR_16C.log

# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2019/software/anaconda3/2018.12/etc/profile.d/conda.sh 
conda activate ~/.conda/envs/limix

# DATA #
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Growth/GWAS/growthPheno.csv

PHENO=/tmp/rosette35DAS_LGR_16C.csv
GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/full_imputed/
OUT=/scratch-cbe/users/pieter.clauw/BOKU/Results/MultiTrait/

awk -F ',' -v OFS=',' '{print $1,$2,$3}' $allphenotypes > $PHENO

MTMM=~/GitRepos/GWAStoolbox/Limix/multitrait.py

python $MTMM -p $PHENO -g $GENO -m 0.05 -o $OUT

rm $PHENO
