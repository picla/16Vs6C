#!/bin/sh

# nextflow script for SNP calling for SNPmatch
# run on login node
# use screen 

# MODULES #
ml nextflow/20.01.0
ml singularity/3.4.1

# DATA #
TAIR10=/scratch-cbe/users/pieter.clauw/16vs6/Data/Genome/TAIR10_chromosomes.fasta
OUTdir=/scratch-cbe/users/pieter.clauw/16vs6/Results/Transcriptome/genotyping/
cd /scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/FASTQraw_trimmed/

# PREPARATIONS #
mkdir /scratch-cbe/users/pieter.clauw/tempFiles

# RUN #
nextflow run ~/GitRepos/nf-haplocaller/main.nf --reads "*bam" --fasta $TAIR10 --outdir $OUTdir -profile standard 

# CLEANUP #
rm -r /scratch-cbe/users/pieter.clauw/tempFiles



