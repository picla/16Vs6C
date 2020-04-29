#!/bin/sh

# PBS #
#PBS -N STAR_align_pseudoG
#PBS -P cegs
#PBS -j oe
#PBS -o Logs/STAR_align_pseudoG_^array_index^.log
#PBS -l walltime=12:00:00,mem=10GB,ncpus=8
#PBS -J 1-10:2

# MODULES #
ml star/2.7.1a-foss-2018b
ml samtools/1.9-foss-2018b 

# DATA #
i=$PBS_ARRAY_INDEX
mainDir=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/

ls -d ${mainDir}/FASTQraw_trimmed/*.fq > fastqList_trimmed.txt

fqLst=${mainDir}fastqList_trimmed.txt
samples=/groups/nordborg/projects/cegs/16Vs6C/Data/Transcriptome/RawData/samples.txt
raw_fq1=$(sed -n ${i}p $fqLst)
raw_fq2=${raw_fq1/end1_val1/end2_val2}

fqbase=$(basename -s .end1.fastq $raw_fq1)
#select sample number (five digit number followed by underscore
sample=$(echo $fqbase | grep -o -E '[0-9]{5}_')
# remove underscore from sample number
sample=${sample%'_'}
accession=$(awk -v sample="$sample" '$1==sample {print $2}' $samples)

if [ $accession = 6909 ]
then
	indices=$HOME/Data/TAIR10/STAR_indices_Araport11_125bpreads/
else
	indices=$HOME/Data/TAIR10/PseudoGenome_STAR_Indices/pseudoTAIR10_${accession}/
fi

echo using STAR indices from: $indices

cores=8
STAR_out=${mainDir}Alignement_STAR_annot/${fqbase}_pseudoG/

mkdir -p $STAR_out

# RUN #
STAR \
--runMode alignReads \
--twopassMode Basic \
--runThreadN $cores \
--alignIntronMax 4000 \
--alignMatesGapMax 4000 \
--outFilterIntronMotifs RemoveNoncanonical \
--outSAMattributes NH HI AS nM NM MD jM jI XS \
--outSAMtype BAM SortedByCoordinate \
--quantMode TranscriptomeSAM \
--genomeDir $indices \
--readFilesIn $raw_fq1 $raw_fq2 \
--outFileNamePrefix $STAR_out

# rezip fastq files #
echo 'rezipping'
pigz $raw_fq1
pigz $raw_fq2

