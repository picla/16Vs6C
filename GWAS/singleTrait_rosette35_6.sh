#!/usr/bin/env bash

# SLURM
#SBATCH--mem=10GB
#SBATCH --output=Logs/rosette35_6C.log

# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh
conda activate ~/.conda/envs/limix

# DATA #
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Growth/GWAS/growthPheno.csv

PHENO=/tmp/rosette35_6C.csv
GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/GWAS/SingleTrait/                                                                                               

awk -F ',' -v OFS=',' '{print $1,$4}' $allphenotypes > $PHENO

LMX=~/GitRepos/BOKU_collab/Scripts/singleloc.py

python $LMX -p $PHENO -g $GENO -m 0.05 -o $OUT







