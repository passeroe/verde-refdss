# Function: Reclassifies rasterStacks with habitat suitability criteria. 
# Outputs RasterBrick with layers of suitable cells by discharge
# Last edited by Elaina Passero on 04/26/19


### Begin function ###
bricks.rc <- function(a,outValRast,hsc_allages,habMets){
  pos <- grep(a,hsc_allages,ignore.case = TRUE)
  hsc <- hsc_allages[pos,] # HSC for current lifestage
  
  acceptRast <- outValRast[[1]]*0 # creates rasterBrick of all 0's where acceptable cells will be added to by discharge
  accept <- 0
  
  for(m in 1:length(habMets)){
      hm <- grep(habMets[m],names(hsc),ignore.case = TRUE) # position of habitat metric in HSC table
      pMin <- min(hm) 
      pMax <- max(hm) # set positions of min and max values for habitat metric
      sDepth <- c(0,hsc[,pMin],0, hsc[,pMin],hsc[,pMax],1, hsc[,pMax],999,0)
      rcDMat <- matrix(sDepth, ncol=3, byrow=TRUE)
      rcDrast <- reclassify(outValRast[[m]], rcDMat)
      acceptRast <- acceptRast + rcDrast
      accept <- accept + 1
  } # end of for loop
  acceptRast[acceptRast < accept] <- NA # Sets any unsuitable cells to NA
  acceptRast[acceptRast == accept] <- 1 # Sets unsuitable cells to 1
  return(acceptRast) # Returns Brick of suitable cells by discharge
} # end of function 
  