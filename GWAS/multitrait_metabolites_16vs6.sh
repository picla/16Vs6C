#!/usr/bin/env bash

# SLURM
#SBATCH --mem=20GB
#SBATCH --output=Logs/metabolite_%A_%a_16vs6.log
#SBATCH --array=2-75:2
# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh 
conda activate ~/.conda/envs/limix

# DATA #
i=$SLURM_ARRAY_TASK_ID
j=$(expr $i + 1)
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Metabolites/GWAS/metabolites.csv
trait=$(head -n 1 $allphenotypes | cut -d',' -f $i | cut -d'_' -f 1)

PHENO=/tmp/{$trait}_16vs6.csv
GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/Metabolites/GWAS/MultiTrait/

# PROCESS #
awk -F ',' -v OFS=',' -v t1="$i" -v t2="$j" '{print $1,$t1,$t2}' $allphenotypes > $PHENO

MTMM=~/GitRepos/GWAStoolbox/Limix/multitrait.py

python $MTMM -p $PHENO -g $GENO -m 0.05 -o $OUT

rm $PHENO
