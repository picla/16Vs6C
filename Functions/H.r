
# calcualet heritabilities in various ways
H <- function(x, print = TRUE){
	
	x <- na.omit(data.frame(id=as.factor(x[,1]), value=as.numeric(as.character(x[,2]))))
	
	# my way
	ve <- aggregate(x$value, list(x$id), var)[,2]
	ve <- na.omit(ve)
	ve <- sum(ve) / length(ve)
	vp <- var(x$value)
	vg <- vp - ve
	H_E <- vg / (vg + ve)

	# update Envel's way - probably wrong
	ve <- var(aggregate(value ~ id, data = x, FUN = mean)[,2])
	vp <- var(x$value)
	vg <- vp - ve
	H_Ev2 <- vg / (vg + ve)
	
	# arthur's

	anv <- anova(lm(value ~ id, data=x))
	mean_nb_rep <- nrow(x) / length(unique(x$id))
	theta_anv <- c((anv$'Mean Sq'[1] - anv$'Mean Sq'[2]) / mean_nb_rep, anv$'Mean Sq'[2])
	H_anv <- theta_anv[1] / (theta_anv[1] + theta_anv[2])

	library(nlme)
	lmm <- lme(value ~ 1, data=x, random= ~ 1|id)	
	theta_lmm <- as.numeric(VarCorr(lmm)[1:2])
	H_lmm <- theta_lmm[1] / (theta_lmm[1] + theta_lmm[2])
	
	if (print == TRUE)
	{
    cat('H_E', H_E, '\n')
  	cat('H_Ev2', H_Ev2, '\n')
  	cat('H_anv ', H_anv, '\n')
  	cat('H_lmm', H_lmm, '\n')
	}
	return(c(H_E, H_Ev2, H_anv, H_lmm))	

}	

# calculate the variance explained by environment (residual variance)
Ve <- function(x)
{
  x <- na.omit(data.frame(id=as.factor(x[,1]), value=as.numeric(as.character(x[,2]))))
  lmm <- lme(value ~ 1, data=x, random= ~ 1|id)	
  theta_lmm <- as.numeric(VarCorr(lmm)[1:2])
  Ve <- theta_lmm[2]
  return(Ve)
}

# calculate the variance explained by genotype
Vg <- function(x)
{
  x <- na.omit(data.frame(id=as.factor(x[,1]), value=as.numeric(as.character(x[,2]))))
  lmm <- lme(value ~ 1, data=x, random= ~ 1|id)	
  theta_lmm <- as.numeric(VarCorr(lmm)[1:2])
  Vg <- theta_lmm[1]
  return(Vg)
}




