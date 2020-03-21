#!/bin/sh

# SLURM # 
#SBATCH --output Logs/bamToFastq_%A_%a.log
#SBATCH --mem=10GB
#SBATCH --array=1-60

#TODO: make list of BAMraw files

# MODULES #
ml bedtools/2.27.1-foss-2018b
ml samtools/1.9-foss-2018b

# DATA #
i=$SLURM_ARRAY_TASK_ID
DATAdir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/
BAMlst=${DATAdir}BAMraw_list.txt
BAM=$(sed "${i}q;d" $BAMlst)
BAMbase=$(basename -s .bam $BAM)

BAMsort=${DATAdir}BAMraw/${BAMbase}.qsort.bam
FASTQ1=${DATAdir}FASTQraw/${BAMbase}.end1.fastq
FASTQ2=${DATAdir}FASTQraw/${BAMbase}.end2.fastq

# sort bam file in order to make 2 fastq files -> paired-end data
samtools sort -n $BAM -o $BAMsort

echo 'bamfile sorted'

# split sorted BAM file into two fastq files (paired-end data)
bedtools bamtofastq -i $BAMsort -fq $FASTQ1 -fq2 $FASTQ2

echo 'bamtofastq finished'


