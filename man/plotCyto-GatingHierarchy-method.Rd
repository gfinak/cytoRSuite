% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotCyto-methods.R
\docType{methods}
\name{plotCyto,GatingHierarchy-method}
\alias{plotCyto,GatingHierarchy-method}
\title{plotCyto - GatingHierarchy Method}
\usage{
\S4method{plotCyto}{GatingHierarchy}(x, parent, alias, channels,
  transList = NULL, overlay = NULL, text.labels, text.legend, main,
  ...)
}
\arguments{
\item{x}{object of class
\code{\link[flowWorkspace:GatingSet-class]{GatingSet}}.}

\item{parent}{name of the population containing the events to plot.}

\item{alias}{name of the gated population for which the gate should be drawn
on the plot.}

\item{channels}{vector of channel names to use for plotting, can be of length
1 for 1D density histogram or length 2 for 2D density plot. If alias is
supplied the channels must be the same as those use to construct the
gate(s).}

\item{transList}{object of class
\code{\link[flowCore:transformList-class]{transformList}} or
\code{\link[flowWorkspace]{transformerList}} generated by
\code{\link[flowCore:logicleTransform]{estimateLogicle}} which was used to
transform the fluorescent channels of the supplied flowFrame. This
transList object will be used internally to ensure axes labels of the plot
are appropriately transformed. The transList will NOT be applied to the
flowFrame internally and should be applied to the flowFrame prior to
plotting.}

\item{overlay}{name(s) of the populations to overlay or a \code{flowFrame},
\code{flowSet}, \code{list of flowFrames}, \code{list of flowSets} or
\code{list of flowFrame lists} containing populations to be overlayed onto
the plot(s).}

\item{text.labels}{vector of names to use in population labels, set to
\code{alias} by default.}

\item{text.legend}{vector of labels to use for the legend if legend is TRUE.}

\item{main}{title to use for the plot, set to the name of the sample and the
name of the parent population by default.}

\item{...}{additional arguments passed to
\code{\link{plotCyto1d,flowSet-method}} or
\code{\link{plotCyto2d,flowSet-method}}.}
}
\description{
Explore & visualise flow cytometry for a GatingHierarchy.
}
\examples{
\dontrun{
  fs <- Activation
  gs <- GatingSet(fs)
  drawGate(gs, parent = "root", alias = "Cells", channels = c("FSC-A","SSC-A"))
  plotCyto(gs[[1]], parent = "root", alias = "Cells", channels = c("FSC-A","SSC-A"))
  drawGate(gs, parent = "Cells", alias = "Single Cells", channels = c("FSC-A","FSC-H"))
  plotCyto(gs[[1]], parent = "Cells", alias = "Single Cells", channels = c("FSC-A","FSC-H"))
}

}
\seealso{
\code{\link{plotCyto1d,flowSet-method}}

\code{\link{plotCyto2d,flowSet-method}}
}
\author{
Dillon Hammill, \email{Dillon.Hammill@anu.edu.au}
}
