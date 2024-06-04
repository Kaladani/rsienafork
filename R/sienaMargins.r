#/******************************************************************************
# * SIENA: Simulation Investigation for Empirical Network Analysis
# *
# * Web: https://www.stats.ox.ac.uk/~snijders/siena/
# *
# * File: sienaMargins.r
# *
# * Description: Used to calculate predicted edge probabilities, to be extended to 
# * calculate (average) marginal effects
# *****************************************************************************/

## We might try to use RSiena:::getTargets() with returnStaticCHangeContribution = TRUE?


# ##@getChangeContributions. Use as RSiena:::getChangeContributions
# getChangeContributions <- function(algorithm, data, effects)
# {
# 	## Gets the simulated statistics.
# 	## The following initializations data, effects, and model
# 	## for calling "getTargets" in "siena07.setup.h"
# 	## is more or less copied from "getTargets" in "getTargets.r".
# 	## However, some modifications have been necessary to get it to work.
# 	f <- unpackData(data,algorithm)

# 	effects <- effects[effects$include,]
# 	if (!is.null(algorithm$settings))
# 	{
# 		stop('not implemented: RI together with settings')
# 		# effects <- addSettingsEffects(effects, algorithm)
# 	}
# 	else
# 	{
# 		effects$setting <- rep("", nrow(effects))
# 	}
# 	pData <- .Call(C_setupData, PACKAGE=pkgname,
# 		list(as.integer(f$observations)),
# 		list(f$nodeSets))
# 	## register a finalizer
# 	ans <- reg.finalizer(pData, clearData, onexit = FALSE)
# 	ans<- .Call(C_OneMode, PACKAGE=pkgname,
# 		pData, list(f$nets))
# 	ans <- .Call(C_Bipartite, PACKAGE=pkgname, # added 1.1-299
# 		pData, list(f$bipartites))
# 	ans<- .Call(C_Behavior, PACKAGE=pkgname, pData,
# 		list(f$behavs))
# 	ans<-.Call(C_ConstantCovariates, PACKAGE=pkgname,
# 		pData, list(f$cCovars))
# 	ans<-.Call(C_ChangingCovariates,PACKAGE=pkgname,
# 		pData,list(f$vCovars))
# 	ans<-.Call(C_DyadicCovariates,PACKAGE=pkgname,
# 		pData,list(f$dycCovars))
# 	ans<-.Call(C_ChangingDyadicCovariates,PACKAGE=pkgname,
# 		pData, list(f$dyvCovars))

# 	storage.mode(effects$parm) <- 'integer'
# 	storage.mode(effects$group) <- 'integer'
# 	storage.mode(effects$period) <- 'integer'

# 	effects$effectPtr <- rep(NA, nrow(effects))
# 	depvarnames <- names(data$depvars)
# 	tmpeffects <- split(effects, effects$name)
# 	myeffectsOrder <- match(depvarnames, names(tmpeffects))
# 	ans <- .Call(C_effects, PACKAGE=pkgname, pData, tmpeffects)
# 	pModel <- ans[[1]][[1]]
# 	for (i in 1:seq_along((ans[[2]])))
# 	{
# 		effectPtr <- ans[[2]][[i]]
# 		tmpeffects[[i]]$effectPtr <- effectPtr
# 	}
# 	myeffects <- tmpeffects
# 	for(i in 1:seq_along((myeffectsOrder)){
# 		myeffects[[i]]<-tmpeffects[[myeffectsOrder[i]]]
# 	}
# 	ans <- .Call(C_getTargets, PACKAGE=pkgname, pData, pModel, myeffects,
# 		parallelrun=TRUE, returnActorStatistics=FALSE,
# 		returnStaticChangeContributions=TRUE)
# 	# See getTargets in siena07setup.cpp; also see rTargets in StatisticsSimulation.cpp
# 	ans
# }

# calculateDistributions <- function(effectContributions = NULL, theta = NULL)
# {
# 	neffects <- dim(effectContributions)[1]
# 	nchoices <- dim(effectContributions)[2]
# 	distributions <- array(NA, dim = c(neffects+1,nchoices))
# 	the.choices <- !is.na(colSums(effectContributions))
# 	if (sum(the.choices) >= 2)
# 	{
# 		distributions[1,the.choices] <-
# 			exp(colSums(theta*effectContributions[,the.choices,drop=FALSE], na.rm=TRUE))/
# 			sum(exp(colSums(theta*effectContributions[,the.choices,drop=FALSE], na.rm=TRUE)))
# 		for(eff in 1:neffects)
# 		{
# 			th <- theta
# 			th[eff] <- 0
# 			distributions[eff+1,the.choices] <-
# 				exp(colSums(th*effectContributions[,the.choices,drop=FALSE], na.rm=TRUE))/
# 				sum(exp(colSums(th*effectContributions[,the.choices,drop=FALSE], na.rm=TRUE)))
# 		}
# 	}
# 	distributions
# }

## Are these the change probabilities or the tie probabilities?

##@expectedChangeProbabilities. Use as RSiena:::expectedChangeProbabilities
expectedChangeProbabilities <- function(conts, effects, theta, thedata=NULL, 
	getChangeStatistics=FALSE, effectNames = NULL)
{
	rms <- function(xx){sqrt((1/dim(xx)[2])*rowSums(xx^2,na.rm=TRUE))}
	waves <- length(conts[[1]])
	effects <- effects[effects$include == TRUE,]
	noRate <- effects$type != "rate"
	effects <- effects[noRate,]
	if(sum(noRate)!=length(theta))
	{
		theta <- theta[noRate]
	}
	effectNa <- attr(conts,"effectNames")
	effectTypes <- attr(conts,"effectTypes")
	networkNames <- attr(conts,"networkNames")
	networkTypes <- attr(conts,"networkTypes")
	networkInteraction <- effects$interaction1
	effectIds <- paste(effectNa,effectTypes,networkInteraction, sep = ".")
	currentDepName <- ""
	depNumber <- 0
	for(eff in 1:length(effectIds))
	{
		if(networkNames[eff] != currentDepName)
		{
			currentDepName <- networkNames[eff]
			actors <- length(conts[[1]][[1]][[1]])
			depNumber <- depNumber + 1
			currentDepEffs <- effects$name == currentDepName
			effNumber <- sum(currentDepEffs)
			depNetwork <- thedata$depvars[[depNumber]]
			if (networkTypes[eff] == "oneMode")
			{
				choices <- actors
			}
			else if (networkTypes[eff] == "behavior")
			{
				choices <- 3
			}
			else if (networkTypes[eff] == "bipartite")
			{
				if (dim(depNetwork)[2] >= actors)
				{
					stop("sienaRI does not work for bipartite networks with second mode >= first mode")
				}
				choices <- dim(depNetwork)[2] + 1
			}
			else
			{
				stop("sienaRI does not work for dependent variables of type 'continuous'")
			}

			# impute for wave 1
			if (networkTypes[eff] %in% c("oneMode", "bipartite"))
			{
				depNetwork[,,1][is.na(depNetwork[,,1])] <- 0
			}
			else
			{
				depNetwork[,,1][is.na(depNetwork[,,1])] <- attr(depNetwork, 'modes')[1]
			}
			# impute for next waves;
			# this may be undesirable for structurals immediately followed by NA...
			for (m in 2:dim(depNetwork)[3]){depNetwork[,,m][is.na(depNetwork[,,m])] <-
				depNetwork[,,m-1][is.na(depNetwork[,,m])]}
				# Make sure the diagonals are not treated as structurals
				if (networkTypes[eff] == "oneMode")
				{
					for (m in 1:(dim(depNetwork)[3])){diag(depNetwork[,,m]) <- 0}
				}
			structurals <- (depNetwork >= 10)
			if (networkTypes[eff] == "oneMode"){
				if (attr(depNetwork, 'symmetric')){
message('\nNote that for symmetric networks, effect sizes are for modelType 2 (forcing).')}}

			#			currentDepObjEffsNames <- paste(effects$shortName[currentDepEffs],
			#				effects$type[currentDepEffs],effects$interaction1[currentDepEffs],sep=".")
			#			otherObjEffsNames <- paste(effects$shortName[!currentDepEffs],
			#				effects$type[!currentDepEffs],effects$interaction1[!currentDepEffs],sep=".")

			absoluteSumActors <- list()
			RHActors <-list()
			changeStats <-list()
			sigma <- list()
			sigmas <- matrix(NA, sum(currentDepEffs), waves)
			for(w in 1:waves)
			{
				currentDepEffectContributions <- conts[[1]][[w]][currentDepEffs]
				if (networkTypes[eff] == "bipartite")
				{
					currentDepEffectContributions <- lapply(
							currentDepEffectContributions,
							function(x){lapply(x,function(xx){xx[1:choices]})})
				}
				# conts[[1]] is periods by effects by actors by actors
				currentDepEffectContributions <-
					sapply(lapply(currentDepEffectContributions, unlist),
						matrix, nrow=actors, ncol=choices, byrow=TRUE,
						simplify="array")
				cdec <- apply(currentDepEffectContributions, c(2,1), as.matrix)
				# cdec is effects by actors (alters) by actors (egos)
				if (dim(currentDepEffectContributions)[3] <= 1) # only one effect
				{
					cdec <- array(cdec, dim=c(1,dim(cdec)))
				}
##
				rownames(cdec) <- effectNa[currentDepEffs]
				if (getChangeStatistics)
				{
					changeStats[[w]] <- cdec
				}
				# replace structural 0s and 1s by NA,
				# so they are omitted from calculation of RI, R_H, sigma
				if (networkTypes[eff] == "oneMode")
				{
					#	structuralsw <- structurals[,,w]
					for (ff in 1:(dim(cdec)[1])){cdec[ff,,][t(structurals[,,w])] <- NA}
				}
				distributions <- apply(cdec, 3,
					calculateDistributions, theta[which(currentDepEffs)])

				# distributions is a list, length = number of actors
				# distributions[[i]] is for actor i, a matrix of dim (effects + 1) * (actors as alters)
				# giving the probability of toggling the tie variable to the alters;
				# the first row is for the unchanged parameter vector theta,
				# each of the following has put one element of theta to 0.
				# for behavior it is a matrix of dim (effects + 1) * 3

			}
		}
	}
distributions
}

## we probably want to extract a tie probability matrix from this

## we should also be able to use code from SienaRIDynamics to calculate the expected probabilitie for each simulation step