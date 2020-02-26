# remove outliers from new annotated data

setwd('/Volumes/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')
lemna <- read.table('Data/Growth/rawdata_combined_annotation.txt', header = T, sep = '\t')
outliers <- read.table('Data/Growth/RawData/outlierList_allREps.txt', head = T)

# PREPARATION
lemna$outlierID <- paste(lemna$pot, lemna$temperature, lemna$replicate, lemna$DAS, sep = '_')
outliers$outlierID <- paste(outliers$pot, outliers$temp, outliers$rep, outliers$DAS, sep = '_')

# extra outliers detected after model prediction
# plants with negative growth predicted from model
# remove all data for
newOutliers <- c('A.6_b6_6C_rep3', 'A.4_a5_6C_rep2', 'C.8_c7_6C_rep1', 'B.1_d6_6C_rep3', 'A.9_b5_6C_rep1', 'D.2_d7_16C_rep2')
newOutlierIDs <- c()
for (DAS in c(14:35))
{
  for (outlierID in newOutliers)
  {
    newOutlierIDs <- c(newOutlierIDs, paste(outlierID, DAS, sep = '_'))
  }
}

# remove two datapoints with extremely high rosette areas
newOutlierIDs <- c(newOutlierIDs, 'B.1_a7_16C_rep1_15', 'D.1_a7_16C_rep1_15')

# remove otliers
lemna.NO <- lemna[!lemna$outlierID %in% c(outliers$outlierID, newOutlierIDs), ]



# write results
write.table(lemna.NO, file = 'Data/Growth/rawdata_combined_annotation_NO.txt', quote = F, row.names = F, sep = '\t')
