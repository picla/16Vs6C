# nonlinear growth modelling using brms for each accession*temperature separately

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

# group by accession and temperature
lemna.sub <- lemna.sub %>%
  group_by(temperature, acn)

# FUNCTION #
model.base.acn <- function(lemna.t.a){
  # priors
  # guestimate M0 prior parameters
  M0_mean <- mean(lemna.t.a$Area.2000px[lemna.t.a$DAS == 0])
  M0_sd <- sd(lemna.t.a$Area.2000px[lemna.t.a$DAS == 0])
  M0_lb <- M0_mean - 1.5 * M0_sd

  stan.vars <- c(
    stanvar(M0_mean, name = 'M0_mean'),
    stanvar(M0_sd, name = 'M0_sd'),
    stanvar(M0_lb, name = 'M0_lb')
  )
  # set priors  
  prior.16C.M0 <- prior(normal(M0_mean, M0_sd), nlpar = 'M0', lb = M0_lb)
  prior.16C.r <- prior(normal(0.5, 0.5), nlpar = 'r', lb = 0)
  prior.16C.beta <- prior(normal(0.8, 0.1), nlpar = 'beta', lb = 0.5)
  
  # model
  fit_acn.t.a <- brm(
    bf(Area.2000px ~ (M0^(1 - beta) + r * DAS_decimal * (1 - beta))^(1 / (1 - beta)),
       M0 ~ 1, r ~ 1, beta ~ 1,
       nl = T),
    data = lemna.t.a,
    prior = c(
      prior.16C.M0,
      prior.16C.r,
      prior.16C.beta),
    cores = 4,
    control = list(adapt_delta = 0.9),
    stanvars = stan.vars
  )
  return(fit_acn.t.a)
}

# RUN #
lemna.fit.base.acn <- group_map(lemna.sub, ~ model.base.acn(.))

# SAVE #
save(lemna.fit.base.acn, file = '/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Results/Growth/nonlinear/lemna.fit.base.rda')




