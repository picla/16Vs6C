#!/bin/sh

# SLURM
#SBATCH --output Logs/fastq2bam_%A_%a.log
#SBATCH --array 1-120:2

# MODULES #
ml build-env/2020
ml picard/2.18.27-java-1.8

# DATA #
end1=$SLURM_ARRAY_TASK_ID
end2=$(expr $end1 + 1)
mainDir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/
fastqList=${mainDir}FASTQraw_trimmed_list.txt
FASTQ1=$(sed "${end1}q;d" $fastqList)
FASTQ2=$(sed "${end2}q;d" $fastqList)
BAM=${FASTQ1/.end1_val_1.fq/.bam}

# CONVERT #
java -jar $EBROOTPICARD/picard.jar FastqToSam \
	F1=$FASTQ1 \
	F2=$FASTQ2 \
	O=$BAM \
	SM='trimmed_unaligned_bam for genotyping'	




