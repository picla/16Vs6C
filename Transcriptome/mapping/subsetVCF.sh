#!/usr/bin/env bash

# SLURM
#SBATCH --mem=5GB
#SBATCH --output=Logs/subsetVCF_%A.log
#SBATCH --array=0-6

ml vcftools/0.1.16-foss-2018b-perl-5.28.0

# DATA #
i=$SLURM_ARRAY_TASK_ID
WORK=/scratch-cbe/users/pieter.clauw/16vs6/Data/Genome/
VCF=${WORK}1001genomes_snp-short-indel_only_ACGTN.vcf.gz

accessions=(6017 9728 9559 8242 9888 9433 9075)

acn=${accessions[$i]}

out=${VCF/.vcf.gz/_${acn}.vcf}
vcf-subset -c $acn $VCF > $out


