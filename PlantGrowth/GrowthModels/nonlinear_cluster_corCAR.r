# script for nonlinear growth modelling
# uses power law function with continuous autoregressive covariance structure between timepoints

# R version 3.5.1 (2018-07-02) -- "Feather Spray"


# setup #
options(stringsAsFactors = F)
library(tidyverse)
library(nlme)
library(optparse)
setwd('/scratch-cbe/users/pieter.clauw/16vs6/')
ctrl <- nlmeControl(msMaxIter = 1000, maxIter = 1000, opt = 'nlminb')

# arguments #
option_list <- list(
    make_option(c("-s", "--subset"), type = "numeric", default=NULL, 
    help = "subset accessions", metavar = "numeric")) 
 
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# self-starting nonlinear power law function in R
# Written by C. Scherber, 4th December 2013
# http://www.christoph-scherber.de/self-starting%20power%20law%20function.txt

# Please acknowledge me should you use this function in publications.
# note that response and explanatory variables need to be strictly positive.

powermodel=function(x,a,b,c)
{a+b*x^c}

powermodelInit=function(mCall,LHS,data){
    xy=sortedXyData(mCall[["x"]],LHS,data)
    lmFit1=lm(xy[,"y"]~1) #for "intercept", a
    lmFit2=lm(log(xy[,"y"])~log(xy[,"x"])) #for b and c
    coefs1=coef(lmFit1)
    coefs2=coef(lmFit2)
    a=coefs1
    b=exp(coefs2[1])
    c=coefs2[2]
    value=c(a,b,c)
    names(value)=mCall[c("a","b","c")]
    value
}

SSpower=selfStart(powermodel,powermodelInit,c("a","b","c"))

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
acns.nr <- length(unique(lemna$acn))
if (!is.null(opt$subset))
{
    acns.nr <- opt$subset
}

lemna.sub <- lemna %>%
  filter(acn %in% unique(lemna$acn)[1:acns.nr]) %>%
  drop_na(Area) %>%
  mutate(
         ID,
         acn = as.factor(acn),
         experiment = as.factor(experiment),
         temperature = as.factor(temperature),
         replicate = as.factor(replicate),
         DAS_decimal,
         DAS = round(DAS_decimal),
         Area) %>%
  select(ID, acn, experiment, temperature, replicate, DAS_decimal, DAS, Area)
 
lemna.sub.grp <- groupedData(Area ~ DAS | ID, data = lemna.sub)

# model #
# run nlsList for starting
fm.lis <- nlsList(Area ~ SSpower(DAS, a, b, c),
    data = lemna.sub.grp,
    control = ctrl)

# run simple mnodel to obtain starting values
fm.nlme.1 <- nlme(fm.lis, 
    control = ctrl)

# get starting values
fm.nlme.1.FE <- fixef(fm.nlme.1)
n.acn <- length(unique(lemna.sub.grp$acn)) - 1                                                                                                          
n.temp <- length(unique(lemna.sub.grp$temperature)) - 1
n <- n.acn + n.temp + n.acn * n.temp
fm.start <- c(fm.nlme.1.FE[1], rep(0, n), fm.nlme.1.FE[2], rep(0, n), fm.nlme.1.FE[3], rep(0, (n.acn + n.temp)))

# adjust fixed effects
fm.nlme.2 <- update(fm.nlme.1, 
    fixed = list(a + b ~ acn * temperature, c ~ acn + temperature),
    start = fm.start,
    control = ctrl, verbose = T)

# include corCAR
fm.nlme.3 <- update(fm.nlme.1,
    fixed = list(a + b ~ acn * temperature, c ~ acn + temperature),
    correlation = corCAR1(form = ~ DAS_decimal),
    start = fm.start,
    control = ctrl, verbose = T)


# save model
save(fm.nlme.3, file = paste('/scratch-cbe/users/pieter.clauw/16vs6/Results/Growth/nonlinear_corCAR_', acns.nr, '.rda', sep = ''))


