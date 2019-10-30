# get estimated marginal means from growth model with fixed experiment interaction


# Setup #
options(stringsAsFactors=F)
library(nlme)
library(emmeans)
library(tidyverse)
setwd('/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')

# Data #
# raw data
lemna <- as.tibble(read.table('Data/Growth/rawdata_combined_annotation_NO.txt', header = T, sep = '\t'))
# model
lme.fit <- get(load('Results/Growth/poly3_logRosette_NO_allReps_V3_corCAR1_expFixed_interaction.rda'))









