\name{includeInteraction}
\alias{includeInteraction}
\title{
Function to create user-specified interactions for a Siena model.
}
\description{This function allows the user to include or exclude
  an interaction effect in a Siena effects object.
}
\usage{
includeInteraction(myeff, ..., include = TRUE, name = myeff$name[1],
    type = "eval", interaction1 = rep("", 3), interaction2 = rep("", 3),
    fix=FALSE, test=FALSE, random=FALSE,
    initialValue=0,
    character = FALSE, verbose = TRUE)
}
\arguments{
  \item{myeff}{a Siena effects object as created by \code{\link{getEffects}},
    which is either an object of class \code{sienaEffects}
    or \code{sienaGroupEffects}.
  }
  \item{\dots}{2 or 3 shortNames to identify the effects
    which should be interacted.
  }
  \item{include}{Boolean. default TRUE, but can be switched to FALSE to
    turn off an interaction.
  }
  \item{name}{Name of dependent variable (network or behavior)
    for which interactions are being defined.
    Defaults to the first in the effects object.
  }
  \item{type}{
    Type of effects to be interacted.
  }
  \item{interaction1}{
    Vector of Siena objects where needed to completely identify the
    effect e.g. covariate name or behavior variable name.
    See the examples below.
    Trailing blanks may be omitted.
  }
  \item{interaction2}{
    Vector of Siena objects where needed to completely identify the
    effect e.g. covariate name or behavior variable name.
    Trailing blanks may be omitted.
  }
  \item{fix}{
    Boolean. Are the effects to be fixed at the value stored in
    \code{myeff$initialValue} or not.}
  \item{test}{
    Boolean. Are the effects to be tested or not (requires \code{fix}).}
  \item{random}{For specifying that the interaction effect will vary randomly;
    not relevant for \code{RSiena} at this moment.
    Boolean required. Default FALSE.}
  \item{initialValue}{Initial value for estimation. Default 0.}
  \item{character}{Boolean: are the effect names character strings or not.}
  \item{verbose}{Boolean: should the print of altered effects be produced.}
}
\details{The details provided should uniquely identify two or three
  effects. If so, an interaction effect will be created and included or
  not in the model. \cr
  Whether interactions between two or three given effects
  can be created depends on their \code{interactionType} (which can be, for
  dependent network variables, empty, ego, or dyadic; and for dependent
  behavioral variables, empty or OK). Consult the section on Interaction
  Effects in the manual for this. The \code{interactionType} is shown
  in the list of effects obtained from the function
  \code{\link{effectsDocumentation}}.\cr
  The short names must not be set between quotes,
  unless you use \code{character=TRUE}.\cr
  From the point of view of model building it is usually advisable, when
  including an interaction effect in a model, also to include the
  corresponding main effects. This is however not enforced
  by \code{includeInteraction}.\cr

  As from version 1.3.24, effects object have a "version" attribute.
  Effects objects including interaction effects are not necessarily compatible
  between versions of \code{RSiena}. Therefore it is recommended to create
  such effects objects again when changing to a new version of \code{RSiena}.
  If an effects object including any interaction effects is used from an
  old version of \code{RSiena}, this will lead to a warning when running
  \code{\link{siena07}}. \cr

  An interaction effect does not have its own internal effect parameter.
  The internal effect parameters of the interacting main effects are used,
  whether or not these are included in the model. This implies that if an
  interaction effect is included but not the corresponding main effects,
  or not all of them, then nevertheless the internal effect parameters as
  specified in the effects object are used for the interaction.
  These can be set using function \code{setEffect} with the desired value
  of \code{parameter} and (in this case) \code{include=FALSE} or
  \code{fix=TRUE, initialValue=0}. \cr
  If an internal effect parameter is changed for one of the main effects
  after the last call of \code{includeInteraction} for a given interaction
  effect, this will not be visible in the name of the interaction effect
  when the effects object is printed.
  However, the correct value of the internal effect parameter
  will be used by \code{\link{siena07}}.\cr
  The values of the internal effect parameters can be checked for a
  \code{\link{sienaFit}} object \code{ans} produced by \code{\link{siena07}}
  by looking at \code{ans$effects}, which is the requested effects object
  to which the main effects of the user-defined interactions were added,
  if they were not included.\cr

  Interaction effects are constructed from effects with shortName
  \code{unspInt} (for networks), \code{behUnspInt} (for discrete behavior),
  and \code{contUnspInt} (for continuous behavior) by specifying their
  elements \code{effect1} and \code{effect2}, and possibly \code{effect3}.
  The shortName is not altered by this function.

  The number of possible user-specified interaction effects is limited
  by the parameters \code{nintn} (for dependent network variables)
  and \code{behNintn} (for dependent behavior variables) in the call of
  \code{\link{getEffects}}, which determine the numbers of effects with
  shortNames \code{unspInt}, \code{behUnspInt}, and \code{contUnspInt}
  (for the latter two, the maximum is \code{behNintn} each).

  The input names \code{interaction1} and \code{interaction2},
  which are vectors as indicated above, do not themselves
  refer to created interactions, but to dependence of the base effects on
  other variables in the data set.
  They are used to completely identify the effects.\cr
  The first element of these vectors applies to the first shortName,
  the second to the second, and if \dots contains 3 shortNames,
  the third to the third. See the list of examples below for the interaction
  between \code{recip} and \code{simX} for an example.

  Further information about Siena effects objects is given
  in the help page for \code{\link{getEffects}}.

  A list of all effects in a given effects object (e.g., \code{myeff}),
  including their names of dependent variables, effect names, short names,
  and values of interaction1 and interaction2 (if any),
  is obtained by executing \code{\link{effectsDocumentation}(myeff)}.
}
\value{
  An updated version of the input effects object; if \code{include},
  containing the interaction effect between "effect1" and "effect2" and
  possibly "effect3"; if not, without this interaction effect.
  The shortName of the interaction effect is "unspInt" for network effects,
  "behUnspInt" for discrete behavior effects, and "contUnspInt" for
  continuous behavior effects. \cr
  If \code{verbose=TRUE}, the interacting effects and the interaction effect
  will be printed, with their row numbers in the effects object.
}
\references{See \url{https://www.stats.ox.ac.uk/~snijders/siena/}}
\author{Ruth Ripley, Tom Snijders}
\seealso{
  \code{\link{getEffects}}, \code{\link{setEffect}},
  \code{\link{includeEffects}}, \code{\link{effectsDocumentation}
}}
\examples{
mynet <- sienaDependent(array(c(s501, s502, s503), dim=c(50, 50, 3)))
alc <- varCovar(s50a)
sm <- varCovar(s50s)
mydata <- sienaDataCreate(mynet, alc, sm)
myeff <- getEffects(mydata)
myeff <- includeInteraction(myeff, recip, inPop)
myeff <- includeEffects(myeff, egoX, altX, simX, interaction1="alc")
myeff <- includeInteraction(myeff, egoX, altX, interaction1=c("alc", "sm"))
myeff <- includeInteraction(myeff, recip, simX, interaction1=c("", "alc"))
myeff <- setEffect(myeff, gwespFF, parameter=20)
myeff <- includeInteraction(myeff, recip, gwespFF)
myeff
(myeff <- setEffect(myeff, gwespFF, parameter=69, include=FALSE))
myeff <- includeInteraction(myeff, recip, gwespFF)
myeff
}
\keyword{ classes }
