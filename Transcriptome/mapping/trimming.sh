#!/bin/sh

# SLURM #
#SBATCH --output Logs/trim_galore_%A_%a.log
#SBATCH --array=1-119:2

# MODULES #
ml trim_galore/0.6.2-foss-2018b-python-3.6.6

# DATA #
end1=$SLURM_ARRAY_TASK_ID
end2=$(expr $end1 + 1)
mainDir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/
OUTdir=${mainDir}FASTQraw_trimmed/
fastqLst=${mainDir}FASTQraw_list.txt

# take fastqs from fastqList.txt
FASTQ1=$(sed "${end1}q;d" $fastqLst)
FASTQ2=$(sed "${end2}q;d" $fastqLst)

# start trim_galor
echo 'starting trim_galore on files:'
echo $FASTQ1
echo $FASTQ2

trim_galore -q 10\
	--fastqc \
	--output_dir $OUTdir \
	--phred33 \
	--paired \
	--nextera \
	$FASTQ1 $FASTQ2

