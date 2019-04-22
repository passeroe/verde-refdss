# This function will read in Delaware raster files for hydraulic habitat variables
# Last edited by Elaina Passero on 4/12/19

load.delaware <- function(wd,reachName,reachCode){
  
tempwd <-paste(wd,"results","/",reachName,"/","rasters",sep = "") # Rasters must be in their own folder
setwd(tempwd)

depthRast <- as.list(list.files(path=tempwd,pattern = "dg.tif")) # pull depth rasters
velRast <- as.list(list.files(path=tempwd,pattern = "vg.tif")) # pull velocity rasters

# get list of modeled discharges
modeled_q <- c()
q_i <- gsub(reachCode,"",velRast)
modeled_q <- parse_number(q_i)

# load rasters
depthRast <- brick(lapply(depthRast,raster))
velRast <- brick(lapply(velRast,raster))

holdList <- list()
holdList$depthRast <- depthRast
holdList$velRast <- velRast
holdList$modeled_q <- modeled_q
# reset working directory
setwd(wd)
return(holdList)
} # end of function

