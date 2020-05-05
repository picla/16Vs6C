#!/bin/sh

# SLURM #
#SBATCH --output Logs/pseudoG_STARidx_%A_%a.log
#SBATCH --mem=40GB
#SBATCH --cpus-per-task=4
#SBATCH --array=1-7

# MODULES #
ml star/2.7.1a-foss-2018b

# DATA #
i=$SLURM_ARRAY_TASK_ID
mainDir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Genome/
pseudoGs=${mainDir}pseudogenomes.txt

ls -d ${mainDir}/pseudogenomes/*.fasta > $pseudoGs


FASTA=$(sed -n ${i}p $pseudoGs)
Indices=${FASTA/.fasta/_STAR_idx/}
Araport11GTF=${mainDir}Araport11_GFF3_genes_transposons.201606.ChrM_ChrC_FullName.gtf
# old
# TAIR10GFF=$HOME/Data/TAIR10/Arabidopsis_thaliana.TAIR10.41.gtf

# PARAMETERS #
cores=4

# PREPARATION #
mkdir -p $Indices

# GENOME INDICES #

STAR \
--runThreadN $cores \
--runMode genomeGenerate \
--genomeDir $Indices \
--genomeFastaFiles $FASTA \
--sjdbGTFfile $Araport11GTF \
--sjdbOverhang 124



