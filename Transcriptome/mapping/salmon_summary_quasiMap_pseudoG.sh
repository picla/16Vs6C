


ml python/3.6.6-foss-2018b
summaryMaker=${HOME}/GitRepos/16Vs6C/Transcriptome/mapping/salmon_summary.py

samples=/groups/nordborg/projects/cegs/16Vs6C/Data/Transcriptome/RawData/samples.txt
salmondir=/scratch-cbe/users/sonia.celestini/SalmonQuant
salmondirs=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/salmondirs_quasiMap_pseudoG.txt
salmonout=/scratch-cbe/users/pieter.clauw/16vs6/Data/Transcriptome/salmon_quasiMap_pseudoG_Trimmed_illumina_summary.csv

find $salmondir -mindepth 1 -maxdepth 1 -type d -name '*_quasiMap_pseudoG_Trimmed' > $salmondirs

python $summaryMaker -s $samples -S $salmondirs -o $salmonout




rm $salmondirs


