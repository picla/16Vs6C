#!/bin/sh

# SLURM #
#SBATCH --output=Logs/snpmatch_%A_%a.log
#SBATCH --array=1-60
#SBATCH --cpus-per-task=8

# MODULES #
ml build-env/2020
ml snpmatch/3.0.1-foss-2018b-python-2.7.15

# DATA #
i=$SLURM_ARRAY_TASK_ID

VCFGZlst=/scratch-cbe/users/pieter.clauw/16vs6/Results/Transcriptome/genotyping/sampleGVCF_list.txt
VCFGZ=$(sed "${i}q;d" $VCFGZlst)
VCF=${VCFGZ/.vcf.gz/.vcf}

DB=/groups/nordborg/projects/the1001genomes/scratch/rahul/101.VCF_1001G_1135/1135g_SNP_BIALLELIC.hetfiltered.snpmat.6oct2015.hdf5
DB_ACC=/groups/nordborg/projects/the1001genomes/scratch/rahul/101.VCF_1001G_1135/1135g_SNP_BIALLELIC.hetfiltered.snpmat.6oct2015.acc.hdf5

base=$(basename -s .g.vcf $VCF)
outfile=/scratch-cbe/users/pieter.clauw/16vs6/Results/Transcriptome/genotyping/snpmatch/${base}

# PREPARE #
gunzip -v $VCFGZ

# RUN #
snpmatch inbred -v -i $VCF -d $DB -e $DB_ACC -o $outfile

# REZIP #
gzip -v $VCF







