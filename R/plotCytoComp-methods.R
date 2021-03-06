#' Plot Compensation
#'
#' Plot each compensation control in all fluorescent channels to identify any
#' potential compensation issues. The unstained control is overlayed in black as
#' a reference.
#'
#' @param x object of class \code{\link[flowCore:flowFrame-class]{flowFrame}} or
#'   \code{\link[flowCore:flowSet-class]{flowSet}} or
#'   \code{\link[flowWorkspace:GatingSet-class]{GatingSet}} containing gated
#'   compensation controls and an unstained control.
#' @param ... additional method-specific arguments.
#'
#' @author Dillon Hammill (Dillon.Hammill@anu.edu.au)
#'
#' @seealso \code{\link{plotCytoComp,flowFrame-method}}
#' @seealso \code{\link{plotCytoComp,flowSet-method}}
#' @seealso \code{\link{plotCytoComp,GatingSet-method}}
#'
#'
#' @export
setGeneric(name = "plotCytoComp",
           def = function(x, ...){standardGeneric("plotCytoComp")}
)

#' Plot Compensation - flowFrame Method
#'
#' Plot each compensation control in all fluorescent channels to identify any
#' potential compensation issues. The unstained control is overlayed in black as
#' a reference.
#'
#' @param x object of class \code{\link[flowCore:flowFrame-class]{flowFrame}}
#'   containing gated compensation controls and an unstained control.
#' @param compensate logical indicating whether the samples should be
#'   compensated prior to plotting, set to FALSE by default. If no spillover
#'   matrix is supplied to the spfile argument the spillover matrix will
#'   extracted from the samples.
#' @param spfile name of spillover matrix csv file including .csv file extension
#'   to use as a starting point for editing. If \code{spfile} is not supplied
#'   the spillover matrix will be extracted directly from the \code{flowFrame}.
#' @param transList object of class
#'   \code{\link[flowCore:transformList-class]{transformList}} or
#'   \code{\link[flowWorkspace]{transformerList}} generated by
#'   \code{\link[flowCore:logicleTransform]{estimateLogicle}} which was used to
#'   transform the fluorescent channels of the supplied flowFrame. This
#'   transList object will be used internally to ensure axes labels of the plot
#'   are appropriately transformed. The transList will NOT be applied to the
#'   flowFrame internally and should be applied to the flowFrame prior to
#'   plotting.
#' @param mfrow vector of grid dimensions \code{c(#rows,#columns)} for each
#'   plot.
#' @param popup logical indicating whether plots should be constructed in a
#'   pop-up window.
#' @param ... additional arguments passed to \code{\link{plotCyto2d,flowFrame-method}}.
#'
#' @importFrom flowWorkspace sampleNames pData
#' @importFrom flowCore parameters compensate
#' @importFrom utils read.csv
#' @importFrom grDevices n2mfrow
#' @importFrom graphics par mtext
#'
#' @author Dillon Hammill (Dillon.Hammill@anu.edu.au)
#' 
#' @seealso \code{\link{plotCyto2d,flowFrame-method}}
#'
#' @examples
#' \dontrun{
#' plotCytoComp(fr, transList = trans, compensate = TRUE, spfile = "Spillover Matrix.csv")
#' }
#'
#' @export
setMethod(plotCytoComp, signature = "flowFrame", 
          definition = function(x, compensate = FALSE, spfile = NULL, transList = NULL, mfrow, popup = FALSE, ...){
            
  # Assign x to fr
  fr <- x
            
  # Sample names
  nm <- fr@description$GUID
            
  # Extract channels
  channels <- getChannels(fr)
  
  # Compensation
  if(compensate == TRUE){
    
    if(is.null(spfile)){
      
      spill <- fr@description$SPILL
      fr <- suppressMessages(compensate(fr, spill))
      
    }else if(!is.null(spfile)){
      
      spill <- read.csv(spfile, header = TRUE, row.names = 1)
      colnames(spill) <- rownames(spill)
      fr <- suppressMessages(compensate(fr, spill))
      
    }
    
  }
            
  # Transformations
  pd <- pData(parameters(fr))
  if(all(pd[pd$name %in% channels, "maxRange"] > 10)){
              
     if(!is.null(transList)){
                
       fr <- suppressMessages(transform(fr, transList))
                
      }else{
                
        trans <- estimateLogicle(fr, channels)
        fr <- suppressMessages(transform(fr, trans))
                
      }
              
  }
            
  # Select channel associated with flowFrame
  chan <- selectChannels(fr)
            
  # Pop-up
  if(popup == TRUE){
              
    checkOSGD()
              
  }
            
  # mfrow
  if(missing(mfrow)){
              
    mfrow <- c(n2mfrow(length(channels))[2], n2mfrow(length(channels))[1])
    par(mfrow = mfrow)
              
  }else if(!missing(mfrow)){
              
    if(mfrow[1] == FALSE){
                
      # Do nothing
                
    }else{
                
      par(mfrow = mfrow)
                
    }
              
  }
            
  # Title space
  par(oma = c(0,0,3,0))
  
  # Plots
  lapply(1:length(channels), function(y){
                  
    plotCyto(fr, channels = c(chan, channels[y]), mfrow = FALSE, transList = transList, legend = FALSE, main = chan, ...)
                  
    if(channels[y] == channels[length(channels)]){
                  
      mtext(nm, outer = TRUE, cex = 1, font = 2)
                  
    }
                
  })
            
  # Return defaults
  par(mfrow = c(1,1))
  par(oma = c(0,0,0,0))
            
  return(NULL)
            
})

#' Plot Compensation - flowSet Method
#'
#' Plot each compensation control in all fluorescent channels to identify any
#' potential compensation issues. The unstained control is overlayed in black as
#' a reference.
#'
#' @param x object of class \code{\link[flowCore:flowSet-class]{flowSet}}
#'   containing gated compensation controls and an unstained control.
#' @param cmfile name of channel match csv file used to match a specific
#'   fluorescent channel to each control. If not supplied user will be guided
#'   through channel selection for each control.
#' @param compensate logical indicating whether the samples should be
#'   compensated prior to plotting, set to FALSE by default. If no spillover
#'   matrix is supplied to the spfile argument the spillover matrix will
#'   extracted from the samples.
#' @param spfile name of spillover matrix csv file including .csv file extension
#'   to use as a starting point for editing. If \code{spfile} is not supplied
#'   the spillover matrix will be extracted directly from the \code{flowSet}.
#' @param transList object of class
#'   \code{\link[flowCore:transformList-class]{transformList}} or
#'   \code{\link[flowWorkspace]{transformerList}} generated by
#'   \code{\link[flowCore:logicleTransform]{estimateLogicle}} which was used to
#'   transform the fluorescent channels of the supplied flowFrame. This
#'   transList object will be used internally to ensure axes labels of the plot
#'   are appropriately transformed. The transList will NOT be applied to the
#'   flowFrame internally and should be applied to the flowFrame prior to
#'   plotting.
#' @param overlay logical indicating whether the unstained control should be
#'   overlayed onto the plot if supplied in the flowSet, set to \code{TRUE} by
#'   default.
#' @param mfrow vector of grid dimensions \code{c(#rows,#columns)} for each
#'   plot.
#' @param popup logical indicating whether plots should be constructed in a
#'   pop-up window.
#' @param ... additional arguments passed to
#'   \code{\link{plotCyto2d,flowFrame-method}}.
#'
#' @importFrom flowWorkspace sampleNames pData
#' @importFrom flowCore parameters compensate
#' @importFrom utils read.csv write.csv
#' @importFrom methods as
#' @importFrom grDevices n2mfrow
#' @importFrom graphics par mtext plot.new
#'
#' @author Dillon Hammill (Dillon.Hammill@anu.edu.au)
#'
#' @examples
#' \dontrun{
#' plotCytoComp(fs, transList = trans, compensate = TRUE, spfile = "Spillover Matrix.csv")
#' }
#'
#' @seealso \code{\link{plotCyto2d,flowFrame-method}}
#'
#' @export
setMethod(plotCytoComp, signature = "flowSet", 
          definition = function(x, cmfile = NULL, compensate = FALSE, spfile = NULL, transList = NULL, overlay = TRUE, mfrow, popup = FALSE, ...){
     
  # Assign x to fs
  fs <- x
  
  # Number of samples
  smp <- length(fs)
  
  # Extract channels
  channels <- getChannels(fs)
  
  # Compensation
  if(compensate == TRUE){
    
    if(is.null(spfile)){
      
      spill <- fs[[1]]@description$SPILL
      fs <- suppressMessages(compensate(fs, spill))
      
    }else if(!is.null(spfile)){
      
      spill <- read.csv(spfile, header = TRUE, row.names = 1)
      colnames(spill) <- rownames(spill)
      
      if(class(fs)[1] == "ncdfFlowSet"){
        
        spill <- lapply(1:length(fs), function(x) spill)
        names(spill) <- pData(fs)$name
        
      }
      
      fs <- suppressMessages(compensate(fs, spill))
      
    }
    
  }
  
  # Transformations
  pd <- pData(parameters(fs[[1]]))
  if(all(pd[pd$name %in% channels, "maxRange"] > 10)){
    
    if(!is.null(transList)){
      
      fs <- suppressMessages(transform(fs, transList))
      
    }else{
      
      trans <- estimateLogicle(as(fs,"flowFrame"), channels)
      fs <- suppressMessages(transform(fs, trans))
      
    }
    
  }
  
  # Channel match file
  if(is.null(cmfile)){
    
    # No cmfile supplied
    message("No cmfile name supplied channels will be selected manually from menu.")
    pData(fs)$channel <- paste(selectChannels(fs))
    
    message("writing new cmfile Compensation Channels.csv to save channel matching.")
    write.csv(pData(fs), "Compensation Channels.csv", row.names = FALSE)
    
  }else if(checkFile(cmfile) == FALSE){
    
    message("Supplied cmfile does not exist in the current working directory.")
    
  }else{
    
    pd <- read.csv(cmfile, header = TRUE, row.names = 1)
    pData(fs)$channel <- paste(pd$channel)
    
  }
  
  # Pull out unstained control if supplied
  if("Unstained" %in% pData(fs)$channel){
    
    unst <- TRUE
    NIL <- fs[[match("Unstained", pData(fs)$channel)]]
    fs <- fs[-match("Unstained", pData(fs)$channel)]
    smp <- smp - 1
    
  }else{
    
    unst <- FALSE
    
  }
  
  # Sample names
  nms <- sampleNames(fs)
  
  # Extract pData from fs
  pdata <- pData(fs)
  
  # Convert fs into list of flowFrames
  fs.lst <- lapply(seq(1,smp,1), function(x) fs[[x]])
  
  # Pop-up
  if(popup == TRUE){
    
    checkOSGD()
    
  }
  
  # mfrow
  if(missing(mfrow)){
    
    mfrow <- c(n2mfrow(length(channels))[2], n2mfrow(length(channels))[1])
    par(mfrow = mfrow)
    
  }else if(!missing(mfrow)){
    
    if(mfrow[1] == FALSE){
      
      # Do nothing
      
    }else{
      
      par(mfrow = mfrow)
      
    }
    
  }
  
  # Title space
  par(oma = c(0,0,3,0))
  
  # Loop through fs.lst
  lapply(1:smp, function(x){
    
    lapply(1:length(channels), function(y){
      
      if(unst == TRUE & overlay == TRUE){
        
        plotCyto(fs.lst[[x]], channels = c(pdata$channel[x], channels[y]), overlay = NIL, mfrow = FALSE, transList = transList, legend = FALSE, main = pdata$channel[x], ...)
      
      }else{
        
        plotCyto(fs.lst[[x]], channels = c(pdata$channel[x], channels[y]), mfrow = FALSE, transList = transList, legend = FALSE, main = pdata$channel[x], ...)
        
      }
      
      # Call new plot
      if(x != smp & channels[y] == channels[length(channels)]){
        
        mtext(nms[x], outer = TRUE, cex = 1, font = 2)
        
        if(popup == TRUE){
          
          checkOSGD()
          par(mfrow = mfrow)
          par(oma = c(0,0,3,0))
          
        }else{
          
          plot.new()
          par(mfrow = mfrow)
          par(oma = c(0,0,3,0))
          
        }
        
      }else if(x == smp & channels[y] == channels[length(channels)]){
        
        mtext(nms[x], outer = TRUE, cex = 1, font = 2)
        
      }
      
    })
    
  })
  
  # Return defaults
  par(mfrow = c(1,1))
  par(oma = c(0,0,0,0))
  
  return(NULL)
            
})
  
#' Plot Compensation - GatingSet Method
#'
#' Plot each compensation control in all fluorescent channels to identify any
#' potential compensation issues. The unstained control is overlayed in black as
#' a reference.
#'
#' @param x object of class
#'   \code{\link[flowWorkspace:GatingSet-class]{GatingSet}} containing gated
#'   compensation controls and an unstained control.
#' @param parent name of the population to plot.
#' @param cmfile name of channel match csv file used to match a specific
#'   fluorescent channel to each control. If not supplied user will be guided
#'   through channel selection for each control.
#' @param compensate logical indicating whether the samples should be
#'   compensated prior to plotting, set to FALSE by default. If no spillover
#'   matrix is supplied to the spfile argument the spillover matrix will
#'   extracted from the samples.
#' @param spfile name of spillover matrix csv file including .csv file extension
#'   to use as a starting point for editing. If \code{spfile} is not supplied
#'   the spillover matrix will be extracted directly from the \code{GatingSet}.
#' @param transList object of class
#'   \code{\link[flowCore:transformList-class]{transformList}} or
#'   \code{\link[flowWorkspace]{transformerList}} generated by
#'   \code{\link[flowCore:logicleTransform]{estimateLogicle}} which was used to
#'   transform the fluorescent channels of the supplied flowFrame. This
#'   transList object will be used internally to ensure axes labels of the plot
#'   are appropriately transformed. The transList will NOT be applied to the
#'   flowFrame internally and should be applied to the flowFrame prior to
#'   plotting.
#' @param mfrow vector of grid dimensions \code{c(#rows,#columns)} for each
#'   plot.
#' @param overlay logical indicating whether the unstained control should be
#'   overlayed onto the plot if supplied in the flowSet, set to \code{TRUE} by
#'   default.
#' @param popup logical indicating whether plots should be constructed in a
#'   pop-up window.
#' @param ... additional arguments passed to \code{\link{plotCyto2d,flowFrame-method}}.
#'
#' @importFrom flowWorkspace sampleNames pData getNodes GatingSet
#' @importFrom flowCore parameters compensate flowSet
#' @importFrom utils read.csv
#' @importFrom methods as
#' @importFrom graphics par
#'
#' @author Dillon Hammill (Dillon.Hammill@anu.edu.au)
#'
#' @examples
#' \dontrun{
#' plotCytoComp(gs, transList = trans, compensate = TRUE, spfile = "Spillover Matrix.csv")
#' }
#'
#' @seealso \code{\link{plotCyto2d,flowFrame-method}}
#'
#' @export
setMethod(plotCytoComp, signature = "GatingSet", 
          definition = function(x, parent = NULL, cmfile = NULL, compensate = FALSE, spfile = NULL, transList = NULL, overlay = TRUE, mfrow, popup = FALSE, ...){            
  
  # Parent
  if(is.null(parent)){
              
    parent <- basename(getNodes(gs))[length(getNodes(gs))]
    message(paste("No parent supplied -",parent, "population will be used for plots."))
              
  }
  
  # Assign x to gs
  gs <- x
  
  # Extract channels
  channels <- getChannels(gs)
  
  # Extract parent
  fs <- getData(gs, parent)  
  
  # Compensation
  if(compensate == TRUE){
    
    if(is.null(spfile)){
      
      spill <- fs[[1]]@description$SPILL
      fs <- suppressMessages(compensate(fs, spill))
      
    }else if(!is.null(spfile)){
      
      spill <- read.csv(spfile, header = TRUE, row.names = 1)
      colnames(spill) <- rownames(spill)
      
      if(class(fs)[1] == "ncdfFlowSet"){
        
        spill <- lapply(1:length(fs), function(x) spill)
        names(spill) <- pData(fs)$name
        
      }
      
      fs <- suppressMessages(compensate(fs, spill))
      
    }
    
  }
  
  # Transformations
  if(is.null(transList)){
    
    trans <- lapply(channels, function(channel) {getTransformations(gs[[1]], channel, only.function = TRUE)})
    names(trans) <- channels
    
    if(all(as.vector(sapply(trans, function(x) {is.null(x)})))){
      
      fr <- as(fs,"flowFrame")
      fr <- flowSet(fr)
      gm <- suppressMessages(GatingSet(fr))
      trans <- estimateLogicle(gm[[1]], channels)
      transList <- transformList(names(trans), lapply(trans, `[[`, "transform"))
      
    }else{
    
      transList <- transformList(channels, trans)
      
    }
    
  }else{
    
    if(class(transList)[1] == "transformerList"){
      
      # Convert transformerList to transformList object
      transList <- transformList(names(transList), lapply(transList, `[[`, "transform"))
      
    }else if(class(transList)[1] == "transformList"){
      
      
      
    }else{
      
      stop("Supplied transList should be of class transformList or transformerList.")
      
    }
    
  }
  
  # Make to plotCytoComp
  plotCytoComp(x = fs, transList = transList, cmfile = cmfile, overlay = overlay, mfrow = mfrow, popup = popup, ...)
  
  # Return defaults
  par(mfrow = c(1,1))
  par(oma = c(0,0,0,0))
  
  return(NULL)
  
})
