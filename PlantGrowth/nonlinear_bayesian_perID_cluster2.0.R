# nonlinear growth modelling using brms for each accession*temperature separately

# SETUP #
options(stringsAsFactors = F)
library(tidyverse)
library(brms)
library(ggpubr)
setwd("/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/")

# DATA #
lemna <- read_delim('Data/Growth/rawdata_combined_annotation_NO.txt', delim = '\t')
fit.lis.coef <- get(load('Results/Growth/nonlinear/models/nlme/fit.lis.coef.rda'))
outliers <- read_delim('Data/Growth/RawData/outlierList_nonlinear_perID.txt', delim = '\t')
args <- commandArgs(trailingOnly=TRUE)
i <- as.integer(args[1])
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
acn <- acns_rep123[i]

# prepare outlier data for filtering
make_outlierIDs <- function(ID, DASlst)
{
  DASs <- c(0:21)
  if(DASlst != 'all'){DASs <- strsplit(DASlst, split = ';')[[1]]}
  outlier.ID <- paste(ID, DASs, sep = '_')
  return (outlier.ID)
}

outlierIDs <- outliers %>%
  filter(remove == 'yes') %>%
  map2(.x = .$ID, .y = .$days, .f = ~make_outlierIDs(.x, .y)) %>%
  unlist()


# subset #
lemna.acn <- lemna %>%
  filter(acn == !!acn, !ID %in% outlierIDs) %>%
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
mean.t0 <- mean(lemna.acn$Area[lemna.acn$DAS == 0])
sd.t0 <- sd(lemna.acn$Area[lemna.acn$DAS == 0])
lemna.acn <- lemna.acn %>%
  mutate(
    Area.2000px = (Area/2000)
  )

# group by ID
lemna.acn <- lemna.acn %>%
  group_by(ID)

# FUNCTION #
model.ID <- function(lemna.ID){
  ID <- as.character(unique(lemna.ID$ID))
  temp <- as.character(unique(lemna.ID$temperature))
  acn <- as.character(unique(lemna.ID$acn))
  rep <- as.character(unique(lemna.ID$replicate))
  # r and beta prior distributions (based on nlsLis results)
  r_beta <- data.frame(
    temperature = c('6C', '16C'),
    r_median = c(0.064, 0.213),
    r_sd = c(0.006, 0.021),
    r_ub = c(0.15, 0.30),
    beta_median = c(0.87, 0.87),
    beta_sd = c(0.005, 0.005))
  
  # priors
  # guestimate M0 prior parameters
  #M0_mean <- mean(lemna.ID$Area.2000px[lemna.ID$DAS == min(lemna.ID$DAS)])
  #M0_sd = 0.5
  #M0_lb <- M0_mean - 1.4 * M0_sd
  #M0_ub <- M0_mean + 1.4 * M0_sd
  #if (M0_lb < 0){M0_lb <- 0}
  
  M0_median <- median(fit.lis.coef$M0[fit.lis.coef$acn == acn & fit.lis.coef$replicate == rep], na.rm = T)
  M0_sd <- 0.2
  
  r_median <- median(fit.lis.coef$r[fit.lis.coef$temperature == temp & fit.lis.coef$acn == acn], na.rm = T)
  r_sd <- sd(fit.lis.coef$r[fit.lis.coef$temperature == temp & fit.lis.coef$acn == acn], na.rm = T)
  #r_median <- r_beta$r_median[r_beta$temperature == temp]
  # use IQR as variance estimate, less affected by the extreme outliers
  #r_sd <- r_beta$r_sd[r_beta$temperature == temp]
  r_ub <- r_beta$r_ub[r_beta$temperature == temp]
  
  #beta_median <- median(fit.lis.coef$beta[fit.lis.coef$temperature == temp], na.rm = T)
  beta_median <- r_beta$beta_median[r_beta$temperature == temp]
  # use IQR as variance estimate, less affected by the extreme outliers
  #beta_iqr <- IQR(fit.lis.coef$beta[fit.lis.coef$temperature == temp], na.rm = T)
  beta_sd <- r_beta$beta_sd[r_beta$temperature == temp]
  
  stan.vars <- c(
    stanvar(M0_median, name = 'M0_median'),
    stanvar(M0_sd, name = 'M0_sd'),
    #stanvar(M0_lb, name = 'M0_lb'),
    #stanvar(M0_ub, name = 'M0_ub'),
    stanvar(r_median, name = 'r_median'),
    stanvar(r_sd, name = 'r_sd'),
    stanvar(r_ub, name = 'r_ub'),
    stanvar(beta_median, name = 'beta_median'),
    stanvar(beta_sd, name = 'beta_sd')
  )
  
  # set priors  
  prior.M0 <- prior(normal(M0_median, M0_sd), nlpar = 'M0', lb = 0, ub = 2.5)
  prior.r <- prior(normal(r_median, r_sd), nlpar = 'r', lb = 0, ub = r_ub)
  prior.beta <- prior(normal(beta_median, beta_sd), nlpar = 'beta', lb = 0.8, ub = 0.9)
  
  # model
  fit.ID <- brm(
    bf(Area.2000px ~ (M0^(1 - beta) + r * DAS_decimal * (1 - beta))^(1 / (1 - beta)),
       M0 ~ 1, r ~ 1, beta ~ 1,
       nl = T),
    data = lemna.ID,
    prior = c(
      prior.M0,
      prior.r,
      prior.beta),
    chains = 8,
    cores = 8,
    iter = 20000,
    control = list(adapt_delta = 0.99),
    stanvars = stan.vars
  )
  # save results
  save(fit.ID, file = paste('/scratch-cbe/users/pieter.clauw/16vs6/Results/Growth/nonlinear/perID/models/bayesian_2.0/fit_',ID, '.rda', sep = ''))
  rm(fit.ID)
}
# RUN #
# clean memory
rm(lemna)
# run model for each accession in temperature
group_map(lemna.acn, ~ model.ID(.), keep = T)





