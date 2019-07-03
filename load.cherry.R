# This function will read in Cherry Creek raster files for hydraulic habitat variables
# Last edited by Elaina Passero on 6/14/19

load.cherry <- function(wd,reachName,reachCode,Check0Flow){
  
  tempwd <-paste(wd,"results","/",reachName,"/",sep = "") # Rasters must be in their own folder
  setwd(tempwd)
  
  depthRast <- as.list(list.files(path=paste(tempwd,"depth","/",sep=""),pattern = "m.tif")) # pull depth rasters
  velRast <- as.list(list.files(path=paste(tempwd,"velocity","/",sep=""),pattern = "m.tif")) # pull velocity rasters
  
  # get modeled discharges
  modeled_q <- unlist(lapply(depthRast, parse_number))
  
  # load rasters
  depthRast <- brick(lapply(depthRast,function(b) raster(x=paste(tempwd,"depth","/",b,sep=""))))
  #if(Check0Flow=="Yes"){
   # pos0 <- as.numeric(match(0,modeled_q)) # gets the position of the zero flow depth raster
  #  vel0Rast <- depthRast[[pos0]]*0 # creates raster of wet cells set to zero velocity
   # writeRaster(vel0Rast,filename=paste(tempwd,"velocity","/",))
   # append(velRast,vel0Rast,after=(pos0-1))
 # }
  velRast <- brick(lapply(velRast,function(b) raster(x=paste(tempwd,"velocity","/",b,sep=""))))
  
  holdList <- list()
  holdList$depthRast <- depthRast
  holdList$velRast <- velRast
  holdList$modeled_q <- modeled_q
  # reset working directory
  setwd(wd)
  return(holdList)
} # end of function