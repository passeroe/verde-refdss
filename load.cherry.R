# This function will read in Cherry Creek raster files for hydraulic habitat variables
# Last edited by Elaina Passero on 5/6/19

load.cherry <- function(wd,reachName,reachCode){
  
  tempwd <-paste(wd,"results","/",reachName,"/",sep = "") # Rasters must be in their own folder
  setwd(tempwd)
  
  depthRast <- as.list(list.files(path=paste(tempwd,"depth","/",sep=""),pattern = "m.tif")) # pull depth rasters
  velRast <- as.list(list.files(path=paste(tempwd,"velocity","/",sep=""),pattern = "m.tif")) # pull velocity rasters
  
  # get modeled discharges
  modeled_q <- unlist(lapply(depthRast, parse_number))
  
  # load rasters
  depthRast <- brick(lapply(depthRast,function(b) raster(x=paste(tempwd,"depth","/",b,sep=""))))
  velRast <- brick(lapply(velRast,function(b) raster(x=paste(tempwd,"velocity","/",b,sep=""))))
  
  holdList <- list()
  holdList$depthRast <- depthRast
  holdList$velRast <- velRast
  holdList$modeled_q <- modeled_q
  # reset working directory
  setwd(wd)
  return(holdList)
} # end of function