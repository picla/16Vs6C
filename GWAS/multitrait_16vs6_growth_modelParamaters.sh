#!/usr/bin/env bash

# SLURM
#SBATCH --mem=20GB
#SBATCH --output=Logs/multitrait_16vs6_growth_%A_%a.log
#SBATCH --array=2-7:2

# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh 
conda activate ~/.conda/envs/limix

# DATA #
i=$SLURM_ARRAY_TASK_ID
j=$((i+1))
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Results/Growth/nonlinear/modelParameters.csv
trait=$(head -n 1 $allphenotypes | cut -d',' -f $i,$j)
trait=${trait/,/_}

PHENO=/tmp/${trait}.csv
GENO=/scratch-cbe/users/pieter.clauw/common_data/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/GWAS/multiTrait/

awk -F ',' -v OFS=',' -v pheno1="$i" -v pheno2="$j" '{print $1,$pheno1,$pheno2}' $allphenotypes > $PHENO

MTMM=~/GitRepos/GWAStoolbox/Limix/multitrait.py

python $MTMM -p $PHENO -g $GENO -m 0.05 -o $OUT

rm $PHENO
