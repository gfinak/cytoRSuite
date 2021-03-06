% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotCytoExprs-methods.R
\docType{methods}
\name{plotCytoExprs,GatingHierarchy-method}
\alias{plotCytoExprs,GatingHierarchy-method}
\title{Plot Population Density Distribution in All Channels - GatingHierarchy Method}
\usage{
\S4method{plotCytoExprs}{GatingHierarchy}(x, parent = NULL,
  channels = NULL, transList = NULL, ...)
}
\arguments{
\item{x}{object of class \code{\link[flowWorkspace:GatingHierarchy-class]{GatingHierarchy}}.}

\item{parent}{name of the population used to construct the plot.}

\item{channels}{a vector channels to use to construct the plots, set to all
channels by default.}

\item{transList}{object of class
\code{\link[flowCore:transformList-class]{transformList}} or
\code{\link[flowWorkspace]{transformerList}} generated by
\code{\link[flowCore:logicleTransform]{estimateLogicle}} which was used to
transform the fluorescent channels of the supplied flowFrame. This
transList object will be used internally to ensure axes labels of the plot
are appropriately transformed. The transList will NOT be applied to the
flowFrame internally and should be applied to the flowFrame prior to
plotting.}

\item{...}{additional arguments passed to \code{\link{plotCyto1d,flowFrame-method}}.}
}
\description{
Plot Population Density Distribution in All Channels - GatingHierarchy Method
}
\examples{
\dontrun{
plotCytoExprs(gh, parent = "root", transList = trans)
}

}
\seealso{
\code{\link{plotCyto1d,flowFrame-method}}

\code{\link{plotCytoExprs,flowFrame-method}}

\code{\link{plotCytoExprs,flowSet-method}}

\code{\link{plotCytoExprs,GatingSet-method}}
}
\author{
Dillon Hammill (Dillon.Hammill@anu.edu.au)
}
