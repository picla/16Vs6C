# script for nonlinear growth modelling
# uses power law function with continuous autoregressive covariance structure between timepoints

# R version 3.5.1 (2018-07-02) -- "Feather Spray"


# setup #
options(stringsAsFactors = F)
library(tidyverse)
library(nlme)
library(optparse)
setwd('/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/')
ctrl <- nlmeControl(msMaxIter = 1000, maxIter = 1000, opt = 'nlminb')

## self start function from ecology paper
# Self-start function for power-law fit. This self-start for this model is not provided by Pinhero and Bates (2000), so I wrote one. Unfortunately, it often does not lead to convergence. Any suggestions would be welcome
fmla.pow <- as.formula("~(M0^(1-beta) + r*x*(1-beta))^(1/(1-beta))")
Init.pow <- function(mCall, LHS, data){
        xy <- sortedXyData(mCall[["x"]], LHS, data)
    if(nrow(xy) < 4) {stop("Too few distinct x values to fit a power-law")}
        r    <-coef(lm(log(y) ~ x, xy))[2]    # Use the slope from a log fit to the data as an initial guess for r
        M0   <- min(xy$y)                     # Use the minimum y value as an initial guess for M0
            beta <- 0.9                           # give initial guess of beta as 0.9. don't use beta = 1, as it's undefined (1/0)   
            value <- c(M0, r, beta)               
                names(value) <- mCall[c("M0", "r", "beta")]
                return(value)
                    }
SS.pow  <- selfStart(fmla.pow, initial = Init.pow, parameters = c("M0", "r", "beta"))
    

# data #
lemna <- read_delim('Data/Growth/rawdata_combined_annotation_NO.txt', delim = '\t')

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
lemna.16C <- lemna %>%
  filter(temperature == '16C') %>%
  drop_na(Area) %>%
  mutate(
         ID,
         acn = as.factor(acn),
         experiment = as.factor(experiment),
         temperature = as.factor(temperature),
         replicate = as.factor(replicate),
         DAS_decimal = DAS_decimal - 14,
         DAS = round(DAS_decimal),
         Area) %>%
  select(ID, acn, experiment, temperature, replicate, DAS_decimal, DAS, Area)

# model #
# load latest succesful model
load('Results/Growth/nonlinear/fit2f.nlme.16C.rda')

# model #
fit2g.nlme.16C <- update(fit2f.nlme.16C,
                        fixed = list(M0 ~ acn, r ~ acn, beta ~ 1),
                        groups = ~ ID,
                        start = fixef(fit2f.nlme.16C),
                        random = pdDiag(list(M0 ~ replicate, r ~ 1, beta ~ 1)),
                        correlation = corCAR1(form =  ~ DAS_decimal),
                        data = lemna.16C,
                        control = ctrl,
                        verbose = T)


# save model
save(fit2g.nlme.16C, file = 'Results/Growth/nonlinear/fit2g.nlme.16C.rda')



