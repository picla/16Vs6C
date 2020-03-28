#!/bin/sh

# PBS #
#PBS -N STAR_align_pseudoG
#PBS -P cegs
#PBS -j oe
#PBS -o Logs/STAR_align_pseudoG_^array_index^.log
#PBS -l walltime=12:00:00,mem=10GB,ncpus=8
#PBS -J 1-10:2

# MODULES #
ml STAR/2.5.3a-foss-2016a
ml SAMtools/1.3.1-foss-2016a

# DATA #
i=$PBS_ARRAY_INDEX
mainDir=${WORK}Transcriptome/6vs16/Data/
fqLst=${mainDir}CD3TJANXX_fastqList.txt
samples=${mainDir}samples.txt
raw_fq1_gz=${mainDir}$(sed -n ${i}p $fqLst)
raw_fq2_gz=${raw_fq1_gz/end1/end2}

raw_fq1=${mainDir}$(basename -s .gz $raw_fq1_gz)
raw_fq2=${mainDir}$(basename -s .gz $raw_fq2_gz)

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

# unzip fastq files #
echo 'unzipping files:'
echo $raw_fq1_gz
echo $raw_fq2_gz

gunzip $raw_fq1_gz
gunzip $raw_fq2_gz

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

