#' Boxed Labels - Modified plotrix
#' 
#' @param x,y  x and y position of the centers of the labels. \code{x} can be a xy.coords list.
#' @param bg The fill color of the rectangles on which the labels are displayed (see Details).
#' @param labels Text strings.
#' @param border Whether to draw borders around the rectangles.
#' @param xpad,ypad The proportion of the rectangles to the extent of the text within.
#' @param srt Rotation of the labels. if 90 or 270 degrees, the box will be rotated 90 degrees.
#' @param cex Character expansion. See \code{text}.
#' @param adj left/right adjustment. If this is set outside the function, the box will not be aligned properly.
#' @param xlog Whether the X axis is a log axis.
#' @param ylog Whether the y axis is a log axis.
#' @param alpha.bg Numeric [0,1] controlling the transparency of the background, set to 0.5 by default.
#' @param ... additional arguments passed to \code{text}.
#' 
#' @author Dillon Hammill (Dillon.Hammill@anu.edu.au)
#' 
#' @importFrom graphics par strwidth strheight rect text
#' @importFrom grDevices col2rgb adjustcolor
#' @importFrom utils modifyList
#' 
#' @noRd
boxed.labels <- function(x, y = NA, labels,
                         bg = ifelse(match(par("bg"), "transparent", 0), "white", par("bg")),
                         border = NA, xpad = 1.2, ypad = 1.2, 
                         srt = 0, cex = 1, adj = 0.5, xlog = FALSE, ylog = FALSE, alpha.bg = 0.5, ...) {
  
  border <- NA
  oldpars <- par(c("cex", "xpd"))
  par(cex = cex, xpd = TRUE)
  if (is.na(y) && is.list(x)) {
    y <- unlist(x[[2]])
    x <- unlist(x[[1]])
  }
  box.adj <- adj + (xpad - 1) * cex * (0.5 - adj)
  if (srt == 90 || srt == 270) {
    bheights <- strwidth(labels)
    theights <- bheights * (1 - box.adj)
    bheights <- bheights * box.adj
    lwidths <- rwidths <- strheight(labels) * 0.5
  }
  else {
    lwidths <- strwidth(labels)
    rwidths <- lwidths * (1 - box.adj)
    lwidths <- lwidths * box.adj
    bheights <- theights <- strheight(labels) * 0.5
  }
  args <- list(x = x, y = y, labels = labels, srt = srt, adj = adj, 
               col = ifelse(colSums(col2rgb(bg) * c(1, 1.4, 0.6)) < 
                              350, "white", "black"))
  args <- modifyList(args, list(...))
  if(xlog){
    xpad<-xpad*2
    xr<-exp(log(x) - lwidths * xpad)
    xl<-exp(log(x) + lwidths * xpad)
  }
  else{
    xr<-x - lwidths * xpad
    xl<-x + lwidths * xpad
  }
  if(ylog){
    ypad<-ypad*2
    yb<-exp(log(y) - bheights * ypad)
    yt<-exp(log(y) + theights * ypad)
  }
  else{
    yb<-y - bheights * ypad
    yt<-y + theights * ypad
  }	
  rect(xr, yb, xl, yt, col = adjustcolor(col = bg, alpha.f = alpha.bg), border = border)
  do.call(text, args)
  par(cex = oldpars)
}

#' Get Appropriate Axes Labels for Transformed Channels - flowWorkspace
#' 
#' @param x object of class \code{flowFrame} or \code{GatingHierarchy}.
#' @param ... additional arguments.
#' 
#' @return list containing axis labels and breaks.
#' 
#' @export
setGeneric(name = "axisLabels",
           def = function(x, ...){standardGeneric("axisLabels")}
)

#' Get Appropriate Axes Labels for Transformed Channels - flowFrame Method
#'
#' @param x an object of class \code{flowFrame}.
#' @param channel name of the channel.
#' @param transList object of class \code{"transformList"} or
#'   \code{"transformerList"} generated by estimateLogicle containing the
#'   transformations applied to the flowFrame.
#'
#' @return list containing axis labels and breaks.
#'
#' @importFrom flowCore transformList inverseLogicleTransform
#'
#' @export
setMethod(axisLabels, signature = "flowFrame", definition = function(x, channel, transList){
  
  if(is.null(transList) | !class(transList)[1] %in%  c("transformList","transformerList")){
    
    stop("Please supply a valid transformList containing the transformations applied to the flowFrame.")
    
  }
  
  if(class(transList)[1] == "transformerList"){
    
    trns <- lapply(transList, `[[`, "transform")
    transList <- transformList(names(trns), trns)
    
  }
  
  if(!channel %in% names(transList@transforms)){
    
    # Channel not listed in trans object
    return(NULL)
    
  }
  
  fr <- x
  
  # Range of values
  r <- as.vector(range(fr)[,channel])

  # Transformation Functions & Breaks
  trans.func <- transList@transforms[[channel]]@f
  inv.func <- inverseLogicleTransform(transList)@transforms[[channel]]@f
  raw <- inv.func(r)
  brks <- flowBreaks(raw, n = 5, equal.space = FALSE)

  
  pos <- signif(trans.func(brks))
  label <- .pretty10exp(brks, drop.1 = TRUE)
  
  res <- list(label = label, at = pos)
  
  return(res)

})

#' Get Appropriate Axes Labels for Transformed Channels - GatingHierarchy Method
#'
#' @param x \code{GatingHiearchy}.
#' @param channel \code{character} channel name.
#'
#' @return when there is transformation function associated with the given
#'   channel, it returns a list of that contains positions and labels to draw on
#'   the axis otherwise returns NULL.
#'
#' @export
setMethod(axisLabels, signature = "GatingHierarchy", definition = function(x, channel){
  
  gh <- x
  res <- gh@axis[[sampleNames(gh)]][[channel]] #this call is to be deprecated once we figure out how to preserve trans when cloning GatingSet
  if(is.null(res)){
    #try to grab trans and do inverse trans for axis label on the fly
    trans <- getTransformations(gh, channel, only.function = FALSE)
    if(is.null(trans)){
      res <- NULL
    }else{
      inv.func <- trans[["inverse"]]
      trans.func <- trans[["transform"]]
      brk.func <- trans[["breaks"]]
      
      fr <- getData(gh, use.exprs = FALSE)
      r <- as.vector(range(fr)[,channel])#range
      raw <- inv.func(r)
      brks <- brk.func(raw)
      pos <- signif(trans.func(brks))
      #format it
      label <- trans[["format"]](brks)
      
      res <- list(label = label, at = pos)
    }
    
  }else{
    #use the stored axis label if exists
    res$label <- .pretty10exp(as.numeric(res$label),drop.1=TRUE)
  }
  
  return(res)
})

#' Generate the breaks that makes sense for flow data visualization - flowWorkspace
#'
#' It is mainly used as helper function to construct breaks function used by 'trans_new'.
#'
#' @return either 10^n intervals or equal-spaced(after transformed) intervals in raw scale.
#' @param n desired number of breaks (the actual number will be different depending on the data range)
#' @param x the raw data values
#' @param equal.space whether breaks at equal-spaced intervals
#' @param trans.fun the transform function (only needed when equal.space is TRUE)
#' @param inverse.fun the inverse function (only needed when equal.space is TRUE)
#' 
#' @noRd
flowBreaks <- function(x, n = 6, equal.space = FALSE, trans.fun, inverse.fun){
  
  rng.raw <- range(x, na.rm = TRUE)
  if(equal.space){
    
    rng <- trans.fun(rng.raw)
    min <- floor(rng[1])
    max <- ceiling(rng[2])
    if (max == min)
      return(inverse.fun(min))
    by <- (max - min)/(n-1)
    
    myBreaks <- inverse.fun(seq(min, max, by = by))
    
  }else{
    #log10 (e.g. 0, 10, 1000, ...)
    base10raw <- unlist(lapply(2:n,function(e)10^e))
    base10raw <- c(0,base10raw)
    myBreaks <- base10raw[base10raw > rng.raw[1] & base10raw < rng.raw[2]]
    
  }
  
  myBreaks
  
}

# copy from sfsmisc/flowWorkspace package
# modified to handle NA values
.pretty10exp <- function (x, drop.1 = FALSE, digits.fuzz = 7){
  
  eT <- floor(log10(abs(x)) + 10^-digits.fuzz)
  mT <- signif(x/10^eT, digits.fuzz)
  ss <- vector("list", length(x))
  
  for (i in seq(along = x)) ss[[i]] <- if (is.na(x[i]))
    quote(NA)
  else if (x[i] == 0)
    quote(0)
  else if (drop.1 && mT[i] == 1)
    substitute(10^E, list(E = eT[i]))
  else if (drop.1 && mT[i] == -1)
    substitute(-10^E, list(E = eT[i]))
  else substitute(A %*% 10^E, list(A = mT[i], E = eT[i]))
  
  do.call("expression", ss)
  
}

#' Get Axes Limits for plotCyto
#'
#' @param x object of class \code{\link[flowCore:flowFrame-class]{flowFrame}} or
#'   \code{\link[flowCore:flowSet-class]{flowSet}}.
#' @param ... additional arguments.
#'
#' @author Dillon Hammill, \email{Dillon.Hammill@anu.edu.au}
#'
#' @noRd
setGeneric(name = "axesLimits",
           def = function(x, ...){standardGeneric("axesLimits")}
)

#' Get Axes Limits for plotCyto - flowFrame Method
#'
#' @param x object of class \code{\link[flowCore:flowFrame-class]{flowFrame}}.
#' @param channels name of the channels or markers to be used to construct the
#'   plot.
#' @param overlay a \code{flowFrame}, \code{flowSet}, \code{list of flowFrames},
#'   \code{list of flowSets} or \code{list of flowFrame lists} containing
#'   populations to be overlayed onto the plot(s).
#' @param upper logical indicating whether the upper limit of the data should be
#'   used for axes limits, set to TRUE by default.
#'
#' @importFrom flowCore exprs flowSet
#'
#' @author Dillon Hammill, \email{Dillon.Hammill@anu.edu.au}
#'
#' @noRd
setMethod(axesLimits, signature = "flowFrame", definition = function(x, channels, overlay = NULL, upper = TRUE){
  
  # Assign x to fr
  fr <- x

  # No overlay
  if(is.null(overlay)){
    
  # overlay
  }else if(!is.null(overlay)){
    
    # flowFrame
    if(class(overlay) == "flowFrame"){
      
      fr <- as(flowSet(list(fr,overlay)),"flowFrame")
      
    # flowSet  
    }else if(class(overlay) == "flowSet"){
      
      ov <- as(overlay, "flowFrame")
      
      if(is.na(match("Original", BiocGenerics::colnames(ov))) == FALSE){
        
          ov <- ov[, -match("Original", BiocGenerics::colnames(ov))]
          
      }
      fr <- as(flowSet(list(fr,ov)),"flowFrame")
      
    # list 
    }else if(class(overlay) == "list"){
      
      # list of flowFrames
      if(all(as.vector(sapply(overlay, function(x) {class(x)})) == "flowFrame"))
      
        fr <- as(flowSet(c(list(fr),overlay)),"flowFrame")
        
      # list of flowSets
      }else if(all(as.vector(sapply(overlay, function(x) {class(x)})) == "flowFrame")){
       
        ov <- lapply(overlay, function(x){as(x,"flowFrame")})
        
        if(is.na(match("Original", BiocGenerics::colnames(ov[[1]]))) == FALSE){
          
          ov <- lapply(ov,function(fr){
            
            fr <- fr[, -match("Original", BiocGenerics::colnames(fr))]
            
            return(fr)
            
          })
        
        }
        fr <- as(flowSet(c(list(fr), ov)),"flowFrame")
        
      # list of lists   
      }else if(all(as.vector(sapply(overlay, function(x) {class(x)})) == "list")){
        
        # flowFrame lists
        if(all(as.vector(sapply(overlay, function(x) {sapply(x,class)})) == "flowFrame")){
          
          fr.lst <- lapply(overlay, function(x){
            
            as(flowSet(x),"flowFrame")
            
          })
          
          if(is.na(match("Original", BiocGenerics::colnames(fr.lst[[1]]))) == FALSE){
            
            ov <- lapply(fr.lst,function(fr){
              
              fr <- fr[, -match("Original", BiocGenerics::colnames(fr))]
              
              return(fr)
              
            })
            
          }
          fr <- as(flowSet(c(list(fr),ov)),"flowFrame")
          
        }
        
        # flowSet lists
        if(all(as.vector(sapply(overlay, function(x) {sapply(x,class)})) == "flowSet")){
          
          fr.lst <- lapply(overlay, function(x){
            
            as(x,"flowFrame")
            
          })
          
          if(is.na(match("Original", BiocGenerics::colnames(fr.lst[[1]]))) == FALSE){
            
            ov <- lapply(fr.lst,function(fr){
              
              fr <- fr[, -match("Original", BiocGenerics::colnames(fr))]
              
              return(fr)
              
            })
          
          fr <- as(flowSet(c(list(fr),ov)),"flowFrame")
          
         }
          
      }
    
    }
    
  }
  
  # Limits from flowFrame
  lim <- lapply(channels, function(channel){
    
    range(exprs(fr)[,channel])
    
  })
  names(lim) <- channels
  
  # xlim & ylim
  xlim <- lim[[1]]
  
  if(length(channels) == 2){
    
    ylim <- lim[[2]]
    
  }
  
  # X axis limits
  if(all(xlim > -5 & xlim < 5)){
      
    # Data on transformed scale
    if(xlim[1] > -0.5){
        
      xlim[1] <- -0.5
        
    }
      
    if(upper == FALSE){
      
      if(xlim[2] < 4.5){
        
        xlim[2] <- 4.5
        
      }
      
    }
      
  }else if(all(xlim > -1000 & xlim < 270000)){
      
    # Data on linear scale
    if(xlim[1] > -1000){
        
      xlim[1] <- -1000
        
    }
      
    if(upper == FALSE){
      
      if(xlim[2] < 265000){
        
        xlim[2] <- 260000
        
      }
      
    }
      
  }
    
  # Y axis limits
  if(length(channels) == 2){
      
    if(all(ylim > -5 & ylim < 5)){
      
      # Data on transformed scale
      if(ylim[1] > -0.5){
        
        ylim[1] <- -0.5
        
      }
      
      if(upper == FALSE){
        
        if(ylim[2] < 4.5){
        
           ylim[2] <- 4.5
        
        }
        
      }
      
    }else if(all(ylim > -1000 & ylim < 270000)){
      
      # Data on linear scale
      if(ylim[1] > -1000){
        
        ylim[1] <- -1000
        
      }
      
      if(upper == FALSE){
        
        if(ylim[2] < 265000){
        
           ylim[2] <- 260000
        
        }
        
      }
      
    }
      
  }
  
  if(length(channels) == 1){
    
    xlim <- list(xlim)
    names(xlim) <- channels[1]
    return(xlim)
    
  }else if(length(channels) == 2){
    
    lim <- list(xlim,ylim)
    names(lim) <- channels
    return(lim)
    
  }
  
})
           
#' Get Axes Limits for plotCyto - flowFrame Method
#' 
#' @param x object of class \code{\link[flowCore:flowSet-class]{flowSet}}.
#' @param channels name of the channels or markers to be used to construct the
#'   plot.
#' @param overlay a \code{flowFrame}, \code{flowSet}, \code{list of flowFrames},
#'   \code{list of flowSets} or \code{list of flowFrame lists} containing
#'   populations to be overlayed onto the plot(s).
#' @param upper logical indicating whether the upper limit of the data should be
#'   used for axes limits, set to TRUE by default.
#'
#' @importFrom methods as
#'
#' @author Dillon Hammill, \email{Dillon.Hammill@anu.edu.au}
#'
#' @noRd
setMethod(axesLimits, signature = "flowSet", definition = function(x, channels, overlay = NULL, upper = TRUE){
  
  # Assign x to fs
  fs <- x
  
  if(length(fs) > 1){
    
    # Coerce to flowFrame
    fr <- as(fs, "flowFrame")
    
    if(is.na(match("Original", BiocGenerics::colnames(fr))) == FALSE){
      
      fr <- fr[, -match("Original", BiocGenerics::colnames(fr))]
      
    }
    
  # Call to axesLimits
  lim <- axesLimits(x = fr, channels = channels, overlay = overlay, upper = upper)
  
  }else{
    
    # Call to axesLimits
    lim <- axesLimits(x = fs[[1]], channels = channels, overlay = overlay, upper = upper)
    
  }
  
  return(lim)
  
})
