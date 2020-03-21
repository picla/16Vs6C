#!/usr/bin/sh

# stage rawdata bamfiles from rawdata repository to scratch-cbe

# SLURM #
#SBATCH --output Logs/stage_bamfiles.log

SAMPLES=/groups/nordborg/projects/cegs/16Vs6C/Data/Transcriptome/RawData/samples.txt
BAMFILES=($(awk 'NR>1 {print $10}' $SAMPLES))

TARGET=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/BAMraw/

for BAM in ${BAMFILES[@]}; do
    cp -v $BAM $TARGET
done


