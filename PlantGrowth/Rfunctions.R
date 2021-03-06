

# FUNCTIONS #
getDate <- function(timeStamp)
{
  if (grepl('[A,P]M', timeStamp))
  {return(format(strptime(timeStamp, format = '%m/%d/%Y %I:%M:%S %p'), '%d.%m.%Y'))}
  else if (!grepl('[A,P]M', timeStamp))
  {return(format(strptime(timeStamp, format = '%d.%m.%Y %H:%M:%S'), '%d.%m.%Y'))}
}

getHour <- function(timeStamp)
{
  if (grepl('[A,P]M', timeStamp))
  {return(format(strptime(timeStamp, format = '%m/%d/%Y %I:%M:%S %p'), '%H:%M'))}
  else if (!grepl('[A,P]M', timeStamp))
  {return(format(strptime(timeStamp, format = '%d.%m.%Y %H:%M:%S'), '%H:%M'))}
}

getExperiment <- function(date, hour)
{
  date <- strptime(date, format = '%d.%m.%Y')
  hour <- strptime(hour, format = '%H:%M')
  noon <- strptime('12:00', format = '%H:%M')
  if (date >= rep1_6C_start & date <= rep1_6C_end){
    return('6C_rep1')
  }  else if (date >= rep1_16C_start & date <= rep1_16C_end){
    return('16C_rep1')
  } else if (date >= rep2_6C_start & date < rep2_6C_end){
    return('6C_rep2')
  }  else if (date == rep2_6C_end & hour < noon){
    return('6C_rep2')
  }  else if (date == rep2_16C_start & hour > noon){
    return('16C_rep2')
  }  else if (date > rep2_16C_start & date < rep2_16C_end){
    return('16C_rep2')
  }  else if (date == rep2_16C_end & hour < noon){
    return('16C_rep2')
  }  else if (date == rep3_6C_start & hour > noon){
    return('6C_rep3')
  }  else if (date > rep3_6C_start & date < rep3_6C_end){
    return('6C_rep3')
  }  else if (date == rep3_6C_end & hour < noon){
    return('6C_rep3')
  }  else if (date == rep3_16C_start & hour > noon){
    return('16C_rep3')
  }  else if (date > rep3_16C_start & date <= rep3_16C_end){
    return('16C_rep3')
  } else {return(NA)}
}

getDAS.decimal <- function(rep, temp, date, hour)
{
  #if(rep == 'rep1_re'){rep <- 'rep1'}
  if (grepl('_re', rep)){rep <- strsplit(rep, split = '_')[[1]][1]}
  DAS1 <- stratification$DAS1[stratification$temp == temp & stratification$rep == rep]
  datehour <- paste(date, hour)
  datehour <- as.POSIXlt(datehour, format = '%d.%m.%Y %H:%M')
  DAS.dec <- as.numeric(difftime(datehour, DAS1, units = 'days')) + 1
  if (length(DAS.dec) == 0){DAS.dec <- NA}
  return(DAS.dec)
}

getAccession <- function(pot, exp)
{
  if (grepl('rep[1,2,3]_re', exp)){exp <- paste(strsplit(exp, split = '_')[[1]][c(1,2)], collapse = '_')}
  random.e <- randomisations[[exp]]
  random.e$pot <- paste(random.e$tray, random.e$coord, sep = '_')
  acn <- random.e$acn[random.e$pot == pot]  
  return(acn)
}

getH_perExp_perDAS <- function(exp, DAS)
{
  hData <- lemna[lemna$experiment == exp & lemna$DAS == DAS, c('acn', 'Area')]
  if (all(is.na(hData$Area))) {return(NA)}
  else {return(H(hData)[4])}
}

getVe_perExp_perDAS <- function(exp, DAS)
{
  hData <- lemna[lemna$experiment == exp & lemna$DAS == DAS, c('acn', 'Area')]
  if (all(is.na(hData$Area))) {return(NA)}
  else {return(Ve(hData))}
}

getVg_perExp_perDAS <- function(exp, DAS)
{
  hData <- lemna[lemna$experiment == exp & lemna$DAS == DAS, c('acn', 'Area')]
  if (all(is.na(hData$Area))) {return(NA)}
  else {return(Vg(hData))}
}


# get slope of linear growth between two timepoints, per accession
getSlope.acn <- function(acn, temp, DAS1, DAS2, emm)
{
  emm.a.t.d <- emm[emm$acn == acn & emm$temp == temp & emm$DAS %in% c(DAS1, DAS2), ]
  fit <- lm(emmean ~ DAS, data = emm.a.t.d)
  return(fit$effects[2])
}


# get slope of linear growth betwene two timepoints, per individual
# OLD VERSION
"getSlope.ind <- function(ID, DAS1, DAS2, growth)
{
  growth.ind <- growth[growth$ID == ID & growth$DAS %in% c(DAS1, DAS2), ]
  if (any(is.na(growth.ind$logArea))){return(NA)}
  else{
  fit <- lm(logArea ~ DAS, data = growth.ind)
  return(fit$effects[2])
  }
}"

# get slope of linear growth over multiple timepoints, per individual
getSlope.ind <- function(ID, DASs, growth)
{
  growth.ind <- growth[growth$ID == ID & growth$DAS %in% DASs, ]
  if (any(is.na(growth.ind$logArea))){return(NA)}
  else{
    fit <- lm(logArea ~ DAS, data = growth.ind)
    return(fit$effects[2])
  }
}

# get resonse curve of linear growth
getRespCurve <- function(acn, growthSlopes)
{
  growthSlopes.a <- growthSlopes[growthSlopes$acn == acn, ]
  fit <- lm(slope ~ temp, data = growthSlopes.a)
  return(fit$effects[2])
}

# predict individual rosette areas from model
predictData.PerExperiment <- function(experiment)
{
  random.e <- randomisations[[experiment]]
  random.e <- random.e[random.e$acn %in% accessions, ]
  random.e$experiment <- experiment
  random.e$temp <- strsplit(experiment, split = '_')[[1]][1]
  random.e$ID <- paste(random.e$tray, random.e$coord, random.e$experiment, sep = '_')
  potNR <- length(random.e$ID)
  DASnr <- length(DASs)
  
  predictData.e <- data.frame('acn' = rep(random.e$acn, DASnr),
                              'DAS' = rep(DASs, each = potNR),
                              'temperature' = rep(random.e$temp, DASnr),
                              'ID' = rep(random.e$ID, DASnr),
                              'experiment' = rep(random.e$experiment, DASnr), stringsAsFactors = F)
}



  
  




