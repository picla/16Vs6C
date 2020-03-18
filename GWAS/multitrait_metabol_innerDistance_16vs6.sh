#!/usr/bin/env bash

# SLURM
#SBATCH --mem=20GB
#SBATCH --output=Logs/metabol_innerDistance_16vs6.log
# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh 
conda activate ~/.conda/envs/limix

# DATA #
PHENO=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Metabolites/GWAS/innerMetabolicDistance.csv

GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/Metabolites/GWAS/MultiTrait/


MTMM=~/GitRepos/GWAStoolbox/Limix/multitrait.py

python $MTMM -p $PHENO -g $GENO -m 0.05 -o $OUT

rm $PHENO
