#!/bin/sh

# PBS directives
#PBS -P cegs
#PBS -N bamToFastq
#PBS -j oe
#PBS -o Logs/bamToFastq_^array_index^.log
#PBS -J 1-5
#PBS -l walltime=6:00:00,mem=10GB

# MODULES #
ml BEDTools/2.26.0-foss-2017a
ml SAMtools/1.6-foss-2017a

# DATA #
i=$PBS_ARRAY_INDEX
DATAdir=/lustre/scratch/users/pieter.clauw/Transcriptome/6vs16/Data/
BAMlst=${DATAdir}CD3TJANXX_bamList.txt
BAM=${DATAdir}$(sed "${i}q;d" $BAMlst)
BAMbase=$(basename -s .bam $BAM)

BAMsort=${DATAdir}${BAMbase}.qsort.bam
FASTQ1=${DATAdir}${BAMbase}.end1.fastq
FASTQ2=${DATAdir}${BAMbase}.end2.fastq

# sort bam file in order to make 2 fastq files -> paired-end data
samtools sort -n $BAM -o $BAMsort

echo 'bamfile sorted'

# split sorted BAM file into two fastq files (paired-end data)
bedtools bamtofastq -i $BAMsort -fq $FASTQ1 -fq2 $FASTQ2

echo 'bamtofastq finished'


