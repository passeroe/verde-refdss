# Function: Reclassifies rasterStacks with habitat suitability criteria. 
# Outputs RasterBrick with layers of suitable cells by discharge
# Last edited by Elaina Passero on 06/17/19 - reclassify changes


### Begin function ###
bricks.rc <- function(a,outValRast,hsc_allages,habMets){
  pos <- grep(a,hsc_allages,ignore.case = TRUE)
  hsc <- hsc_allages[pos,] # HSC for current lifestage
  
  acceptRast <- setValues(outValRast[[1]],0) # creates rasterBrick of all 0's where acceptable cells will be added to by discharge
  
  for(m in 1:length(habMets)){
      hm <- grep(habMets[m],names(hsc),ignore.case = TRUE) # position of habitat metric in HSC table
      pMin <- min(hm) 
      pMax <- max(hm) # set positions of min and max values for habitat metric
      sDepth <- c(-999,hsc[,pMin],NA, hsc[,pMin],hsc[,pMax],1, hsc[,pMax],999,NA)
      rcDMat <- matrix(sDepth, ncol=3, byrow=TRUE)
      rcDrast <- reclassify(outValRast[[m]], rcDMat,right=FALSE)
      acceptRast <- acceptRast + rcDrast # any value + NA yields NA; cells either number of habitat metrics or NA
  } # end of for loop
  return(acceptRast) # Returns Brick of suitable cells by discharge
} # end of function 
