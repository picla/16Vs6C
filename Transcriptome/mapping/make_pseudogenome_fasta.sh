#!/bin/sh

# PBS #
#PBS -N makePseudoGenomes
#PBS -P cegs
#PBS -j oe
#PBS -o Logs/makePseudeGenomes_^array_index^.log
#PBS -l walltime=12:00:00,mem=10GB
#PBS -J 1-3

# MODULES #
ml Python/3.6.4-foss-2018a
# copy script from /projects/cegs/6vs16/Scripts/make_pseudogenome_fasta.py
PSEUDOGENIZE=${WORK}Transcriptome/6vs16/Scripts/make_pseudogenome_fasta.py 

# DATA #
i=$PBS_ARRAY_INDEX
mainDir=${WORK}Transcriptome/6vs16/Data/Genome/
FASTA=${mainDir}TAIR10_genome.fasta
VCFlst=${mainDir}vcf_for_pseudoGenome.txt
VCF=${mainDir}$(sed -n ${i}p $VCFlst)
OUT=${VCF/intersection/pseudoTAIR10}
OUT=${OUT/.vcf/.fasta}

# MAKE PSEUDO GENOMES #
python $PSEUDOGENIZE -O $OUT $FASTA $VCF

awk '/>[0-9]/{gsub(/>/,">Chr")}{print}' $OUT > ${OUT}.tmp
mv ${OUT}.tmp $OUT






