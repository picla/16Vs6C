# script for modelling the growth
# calculation of least square means for each accession

# needs more than 10GB
# R version 3.4.0 (2017-04-21) -- "You Stupid Darkness"


library(nlme)
library(emmeans)

setwd('/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')

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
lemnaSlim.poly <- lme(logArea ~ (DAS + I(DAS^2) + I(DAS^3)) * acn * temperature, random = ~ 1 + DAS|experiment/ID, data = lemnaSlim, na.action = na.exclude, control=lmeControl(singular.ok=TRUE, returnObject=TRUE), correlation = corCAR1(form = ~ DAS|experiment/ID))

#save(lemnaSlim.poly, file = "Results/Growth/poly3_logRosette.rda")
save(lemnaSlim.poly, file = "Results/Growth/poly3_logRosette_NO_allReps_V3_corCAR1_correct.rda")

# residuals
pdf('Results/Growth/Plots/poly3_logRosette_NO_allReps_resiudals_V3_corCAR1_correct.pdf')
plot(lemnaSlim.poly)
dev.off()

#emmeans
# set timepoints to get estimates
time0 <- min(unique(lemna$DAS))
timeX <- max(unique(lemna$DAS))
timepoints <- seq(time0, timeX, length.out = 21)


# emmeans - model with temperature as fixed effect
acns <- unique(lemna$acn)
acnTime <- c()
for (a in acns)
{
  acnTime <- c(acnTime, rep(a, 2 * length(timepoints)))
}
time6C <- rep('6C', length(timepoints))
time16C <- rep('16C', length(timepoints))


predictionData <- data.frame('acn' = acnTime, 'DAS' = rep(timepoints, 2 * length(acns)), 'temperature' = rep(c(time6C, time16C), length(acns)))


#adjM <- lsmeans(lemnaSlim.poly, ~ DAS * acn * temp, cov.reduce = FALSE, data = predictionData)
#s <- summary(adjM)
#lsm <- data.frame('DAS' = s$DAS, 'acn' = s$acn, 'temp' = s$temp, 'lsmean' = s$lsmean, 'SE' = s$SE, 'df' = s$df)

#write.table(lsm, file = "Results/Growth/lemna_DAS_allReps_NO_logRosette_lsmeans.txt", sep = "\t", quote = F, row.names = F)


adjM <- emmeans(lemnaSlim.poly, ~ DAS * acn * temperature, cov.reduce = FALSE, data = predictionData)
s <- summary(adjM)
emm <- data.frame('DAS' = s$DAS, 'acn' = s$acn, 'temp' = s$temp, 'emmean' = s$emmean, 'SE' = s$SE, 'df' = s$df)

write.table(emm, file = "Results/Growth/lemna_DAS_allReps_NO_logRosette_emmeans_V3_CorCAR1_correct.txt", sep = "\t", quote = F, row.names = F)

