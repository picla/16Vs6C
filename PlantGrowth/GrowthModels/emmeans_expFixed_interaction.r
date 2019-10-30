# get estimated marginal means from growth model with fixed experiment interaction


# Setup #
options(stringsAsFactors=F)
library(nlme)
library(emmeans)
library(tidyverse)
setwd('/Volumes/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')

# Data #
# raw data
lemna <- read_delim('Data/Growth/rawdata_combined_annotation_NO.txt', delim = '\t')
# model
lme.fit <- get(load('Results/Growth/poly3_logRosette_NO_allReps_V3_corCAR1_expFixed_interaction.rda'))
# accesisons
accessions <- read_table('Setup/accessionList.rep1.2.3.txt', col_names = 'accession', skip = 1) %>% .$accession
#DASs
DASs <- unique(lemna$DAS)
# experiments
experiments <- unique(lemna$experiment)


# Prediciton data
## only use accession present in all experiments
lemna <- lemna %>%
  filter(acn %in% accessions)


## create prediction data
predictionData <- data.frame(
  'acn' = rep(accessions, each = length(DASs)*length(experiments)),
  'DAS' = rep(rep(DASs, each = length(experiments)), length(accessions)),
  'experiment' = rep(experiments, length(accessions)*length(DASs)))













