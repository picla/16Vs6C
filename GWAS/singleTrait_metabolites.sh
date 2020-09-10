#!/usr/bin/env bash

# SLURM
#SBATCH --mem=10GB
#SBATCH --output=Logs/singleTrait_metabolite_%A_%a.log
#SBATCH --array=2-75

# ENVIRONMENT #
ml anaconda3/2019.03
source /software/2020/software/anaconda3/2019.03/etc/profile.d/conda.sh
conda activate ~/.conda/envs/limix

# DATA #
i=$SLURM_ARRAY_TASK_ID
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Metabolites/GWAS/metabolites.csv
trait=$(head -n 1 $allphenotypes | cut -d',' -f $i)

PHENO=/tmp/{$trait}.csv
GENO=/scratch-cbe/users/pieter.clauw/genotypes_for_pygwas/1.0.0/1001genomes/
OUT=/scratch-cbe/users/pieter.clauw/16vs6/Results/Metabolites/GWAS/SingleTrait/                                                                                      
awk -F ',' -v OFS=',' -v col="$i" '{print $1,$col}' $allphenotypes > $PHENO

LMX=~/GitRepos/GWAStoolbox/Limix/singletrait.py  BOKU_collab/Scripts/singleloc.py

python $LMX -p $PHENO -g $GENO -m 0.05 -o $OUT







