# nonlinear growth modelling using brms for 16C

# SETUP #
options(stringsAsFactors = F)
library(tidyverse)
library(brms)
library(ggpubr)
setwd("/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/")

# DATA #
lemna <- read_delim('Data/Growth/rawdata_combined_annotation_NO.txt', delim = '\t')

# PREPARATIONS #
# data preparation #
lemna$ID <- paste(lemna$pot, lemna$experiment, sep = '_')
lemna$acn <- as.character(lemna$acn)
lemna$Area[lemna$Area == 0] <- NA

# only use accessions which have data for all replicates
acns_rep1 <- unique(lemna$acn[lemna$replicate == 'rep1'])
acns_rep2 <- unique(lemna$acn[lemna$replicate == 'rep2'])
acns_rep3 <- unique(lemna$acn[lemna$replicate == 'rep3'])

acns_rep123 <- intersect(intersect(acns_rep2, acns_rep3), acns_rep1)
lemna <- lemna[lemna$acn %in% acns_rep123, ]

# subset #
lemna.sub <- lemna %>%
  drop_na(Area) %>%
  mutate(
    ID,
    acn = as.factor(acn),
    experiment = as.factor(experiment),
    temperature = as.factor(temperature),
    replicate = as.factor(replicate),
    DAS_decimal = DAS_decimal - 14,
    DAS = floor(DAS_decimal),
    Area) %>%
  select(ID, acn, experiment, temperature, replicate, DAS_decimal, DAS, Area)


# Area transformations
mean.t0 <- mean(lemna.sub$Area[lemna.sub$DAS == 0])
sd.t0 <- sd(lemna.sub$Area[lemna.sub$DAS == 0])
lemna.sub <- lemna.sub %>%
  mutate(
    Area.2000px = (Area/2000)
  )

lemna.16C <- filter(lemna.sub, temperature == '16C')


cprior <- prior(normal(0.80, 0.44), nlpar = 'M0', lb = 0) +
  prior(normal(0.5, 0.5), nlpar = 'r', lb = 0) +
  prior(normal(0.9, 0.1), nlpar = 'beta', lb = 0.5)

fit_16C_acns.e <- brm(
  bf(Area.2000px ~ (M0^(1 - beta) + r * DAS_decimal * (1 - beta))^(1 / (1 - beta)),
     M0 ~ acn, r ~ acn, beta ~ 1,
     nl = T),
  data = lemna.16C,
  prior = cprior,
  cores = 4
)

save(fit_16C_acns.e, file = 'Results/Growth/nonlinear/fit_16C_acns.e.rda')





