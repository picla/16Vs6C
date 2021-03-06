# script for modelling the growth
# using maximum likelhood instead of REML. Sole use to compare between model. Final estimnates should be taken from REML models.



library(nlme)
library(emmeans)

setwd('/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')
#source('Scripts/Growth/Functions/rawPlot.r')

# read in data
lemna <- read.table('Data/Growth/rawdata_combined_annotation_NO.txt', header = T, sep = '\t')


# prepare data
lemna$acn <- as.character(lemna$acn)
lemna$Area[lemna$Area == 0] <- NA
lemna$logArea <- log(lemna$Area)

# only use accessions which have data for all replicates
acns_rep1 <- unique(lemna$acn[lemna$rep == 'rep1'])
acns_rep2 <- unique(lemna$acn[lemna$rep == 'rep2'])
acns_rep3 <- unique(lemna$acn[lemna$rep == 'rep3'])

acns_rep123 <- intersect(intersect(acns_rep2, acns_rep3), acns_rep1)
lemna <- lemna[lemna$acn %in% acns_rep123, ]

# DAS_decimal is used as time, taking full power of having morning and evening measurements
lemna$pot <- as.character(lemna$pot)
lemna$block <- substr(lemna$pot, 1, 1)
lemna$ID <- paste(lemna$pot, lemna$experiment, sep = '_')

# model
lemnaSlim <- lemna[ ,c('acn', 'temperature', 'logArea', 'experiment', 'ID')]
lemnaSlim$DAS <- lemna$DAS_decimal
lemnaSlim$acn <- as.factor(lemnaSlim$acn)
lemnaSlim$temperature <- as.factor(lemnaSlim$temperature)
lemnaSlim$experiment <- as.factor(lemna$experiment)
lemnaSlim$ID <- as.factor(lemna$ID)
# the model
# lemnaSlim.poly <- lme(logArea ~ (DAS + I(DAS^2) + I(DAS^3)) * acn * temp, random = ~ 1 + (DAS + I(DAS^2) + I(DAS^3))|experiment, correlation = corCAR1() , data = lemnaSlim, na.action = na.exclude)

#lemnaSlim.poly <- lme(logArea ~ (DAS + I(DAS^2) + I(DAS^3)) * acn * temp, random = ~ 1|experiment, correlation = corCAR1() , data = lemnaSlim, na.action = na.exclude)

# TODO: model with cor structure currently does not converge. Work on this??
# model5 <- lme(logArea ~ (DAS + I(DAS^2) + I(DAS^3)) * acn * temp, random = ~ 1 + DAS|experiment/ID, correlation = corCAR1(form = ~DAS|experiment/ID), data = lemnaSlim, na.action = na.exclude)
lemnaSlim.poly <- lme(logArea ~ (DAS + I(DAS^2) + I(DAS^3)) * acn * experiment, random = ~ 1 + DAS|experiment/ID, data = lemnaSlim, na.action = na.exclude, control=lmeControl(singular.ok=TRUE, returnObject=TRUE), correlation = corCAR1(form = ~ DAS|experiment/ID), method = 'ML')

#save(lemnaSlim.poly, file = "Results/Growth/poly3_logRosette.rda")
save(lemnaSlim.poly, file = "Results/Growth/poly3_logRosette_NO_allReps_V3_corCAR1_expFixed_interaction_ML.rda")

# residuals
pdf('Results/Growth/Plots/poly3_logRosette_NO_allReps_resiudals_V3_corCAR1_expFixed_interaction_ML.pdf')
plot(lemnaSlim.poly)
dev.off()

