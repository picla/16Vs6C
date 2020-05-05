#!/bin/sh

# SLURM #
#SBATCH --output Logs/makePseudeGenomes_%A_%a.log
#SBATCH --mem=10GB
#SBATCH --array=1-7

# MODULES #
ml python/3.6.6-foss-2018b
# copy script from /projects/cegs/6vs16/Scripts/make_pseudogenome_fasta.py
PSEUDOGENIZE=~/GitRepos/16Vs6C/Transcriptome/mapping/make_pseudogenome_fasta.py 

# DATA #
i=$SLURM_ARRAY_TASK_ID
mainDir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Genome/
FASTA=${mainDir}TAIR10_chromosomes.fas
VCFlst=${mainDir}vcf_for_pseudogenome.txt
VCF=$(sed -n ${i}p $VCFlst)
OUT=${VCF/1001genomes_snp-short-indel_only_ACGTN/pseudogenomes/pseudoTAIR10}
OUT=${OUT/.vcf/.fasta}

mkdir -p ${maibnDir}pseudogenomes/

# MAKE PSEUDO GENOMES #
python $PSEUDOGENIZE -O $OUT $FASTA $VCF

awk '/>[0-9]/{gsub(/>/,">Chr")}{print}' $OUT > ${OUT}.tmp
mv ${OUT}.tmp $OUT






