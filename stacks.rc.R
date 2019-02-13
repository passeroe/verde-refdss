# Function: Reclassifies rasterStacks with habitat suitability criteria. 
# Outputs RasterBrick with layers of suitable cells by discharge
# Last edited by Elaina Passero on 02/13/19


### Begin function ###
stacks.rc <-function(iricValRast,hsc,habMets) {
    acceptRast <- iricValRast[[1]]*0 # creates rasterBrick of all 0's where acceptable cells will be added to by discharge
  if("Depth" %in% names(iricValRast)) {
    sDepth <- c(0,hsc$depthmin,0, hsc$depthmin,hsc$depthmax,1, hsc$depthmax,999,0)
    rcDMat <- matrix(sDepth, ncol=3, byrow=TRUE)
    rcDrast <- reclassify(iricValRast$Depth, rcDMat)
    acceptRast <- acceptRast + rcDrast
    accept <- 1
  }
  if("VelocityMag" %in% names(iricValRast)) {
    sVel <- c(0,hsc$velmin,0, hsc$velmin,hsc$velmax,1, hsc$velmax,999,0)
    rcVMat <- matrix(sVel, ncol=3, byrow=TRUE)
    rcVrast <- reclassify(iricValRast$VelocityMag, rcVMat)
    acceptRast <- acceptRast + rcVrast
    accept <- accept+1
  }
  if("ShearSMag" %in% names(iricValRast)){
    sShe <- c(0,hsc$shemin,0, hsc$shemin,hsc$shemax,1, hsc$shemax,999,0)
    rcSMat <- matrix(sShe, ncol=3, byrow=TRUE)
    rcSrast <- reclassify(iricValRast$VelocityMag, rcVMat)
    acceptRast <- acceptRast + rcSrast
    accept <- accept+1    
  }
  acceptRast[acceptRast < accept] <- NA # Sets any unsuitable cells to NA
  return(acceptRast) # Returns Brick of suitable cells by discharge
} # end function
