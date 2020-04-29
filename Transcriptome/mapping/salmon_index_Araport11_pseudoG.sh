#!/bin/sh

# script to build the transcriptome index for the Araport11 transcriptome that can be used for gene expression quantification with salmon (non-alignement based)

# PBS #
#PBS -N salmonIdx
#PBS -P cegs
#PBS -j oe
#PBS -o Logs/salmon_index_PseudoG_^array_index^.log
#PBS -l walltime=1:00:00
#PBS -J 0-3


# MODULES #
ml Salmon/0.12.0-foss-2018b-Python-2.7.15

# DATA #
i=$PBS_ARRAY_INDEX
DATA=/lustre/scratch/users/pieter.clauw/Transcriptome/6vs16/Data/

accessions=('6909' '9559' '6017' '9728') 
acn=${accessions[$i]}

if [ $acn = 6909 ]
then
        TRANSCRIPT=${DATA}Genome/TAIR10_transcriptome.fasta
	INDEX=${DATA}Genome/Araport11_transcriptome_6909_salmonIdx
else
        TRANSCRIPT=${DATA}Genome/pseudoTAIR10_${acn}_transcriptome.fasta
	INDEX=${DATA}Genome/Araport11_transcriptome_${acn}_salmonIdx
fi

echo for accession $accession we are using transcriptome from: $TRANSCRIPT

# build index
salmon index -t $TRANSCRIPT -k 31 -i $INDEX --keepDuplicates

echo index for salmon quasi-mapping has been built and saved in $INDEX
