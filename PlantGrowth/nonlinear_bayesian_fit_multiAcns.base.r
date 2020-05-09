# nonlinear growth modelling using brms for 16C

# SETUP #
options(stringsAsFactors = F)
library(tidyverse)
library(brms)
library(ggpubr)
setwd("/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/")

# DATA #
lemna <- read_delim('Data/Growth/rawdata_combined_annotation_NO.txt', delim = '\t')
args <- commandArgs(trailingOnly=TRUE)
temp <- args[1]

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

lemna.t <- filter(lemna.sub, temperature == temp)


# MODEL #

# priors
M0_mean <- mean(lemna.t$Area.2000px[lemna.t$DAS == 0], na.rm = T)
M0_sd <- sd(lemna.t$Area.2000px[lemna.t$DAS == 0], na.rm = T)
M0_lb <- M0_mean - 1.4 * M0_sd
M0_ub <- M0_mean + 1.4 * M0_sd
if (M0_lb < 0){M0_lb <- 0}

stan.vars <- c(
  stanvar(M0_mean, name = 'M0_mean'),
  stanvar(M0_sd, name = 'M0_sd'),
  stanvar(M0_lb, name = 'M0_lb'),
  stanvar(M0_ub, name = 'M0_ub')
)
# set priors  
prior.16C.M0 <- prior(normal(M0_mean, M0_sd), nlpar = 'M0', lb = M0_lb)
prior.16C.r <- prior(normal(0.5, 0.5), nlpar = 'r', lb = 0, ub = 1.5)
prior.16C.beta <- prior(normal(0.8, 0.1), nlpar = 'beta', lb = 0.5, ub = 1.5)

# model
fit.t <- brm(
  bf(Area.2000px ~ (M0^(1 - beta) + r * DAS_decimal * (1 - beta))^(1 / (1 - beta)),
     beta ~ 1,
     M0 ~ 0 + acn,
     r ~ 0 + acn,
     autocor = ~ ar(time = DAS_decimal, gr = ID, p = 4),
     nl = T),
  data = lemna.t,
  prior = c(
    prior.16C.M0,
    prior.16C.r,
    prior.16C.beta),
  cores = 4,
  control = list(adapt_delta = 0.9),
  stanvars = stan.vars
)

save(fit_16C.sub.g, file = paste('Results/Growth/nonlinear/fit_multiAcns_', temp, '.rda', sep = ''))


