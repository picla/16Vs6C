#!/usr/bin/env bash

# SLURM
#SBATCH--mem=20GB
#SBATCH --output=Logs/rosette35DAS_16vs6.log

# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh
conda activate ~/.conda/envs/limix

# DATA #
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Growth/GWAS/growthPheno.csv

PHENO=/tmp/rosette35DAS_16vs6.csv
GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/GWAS/MultiTrait/

awk -F ',' -v OFS=',' '{print $1,$2,$4}' $allphenotypes > $PHENO

MTMM=~/GitRepos/GWAStoolbox/Limix/multitrait.py

python $MTMM -p $PHENO -g $GENO -m 0.05 -o $OUT

rm $PHENO
