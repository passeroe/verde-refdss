# This function will read in Cherry Creek raster files for hydraulic habitat variables
# Last edited by Elaina Passero on 10/21/19

load.cherry <- function(reach_wd,Check0Flow){
  
  tempwd <-paste(reach_wd,"model_outputs","/",sep = "") # Rasters must be in their own folder
  
  depth_rast <- as.list(list.files(path=paste(tempwd,"depth","/",sep=""),pattern = "m.tif")) # pull depth rasters
  vel_rast <- as.list(list.files(path=paste(tempwd,"velocity","/",sep=""),pattern = "m.tif")) # pull velocity rasters
  
  # get modeled discharges
  modeled_q <- unlist(lapply(depth_rast, parse_number))
  
  # load rasters
  depth_rast <- brick(lapply(depth_rast,function(b) raster(x=paste(tempwd,"depth","/",b,sep=""))))
  if(Check0Flow=="Yes"){
    pos0 <- as.numeric(match(0,modeled_q)) # gets the position of the zero flow depth raster
    vel_0_rast <- depth_rast[[pos0]]*0 # creates raster of wet cells set to zero velocity
    writeRaster(vel_0_rast,filename=paste(tempwd,"velocity","/","v_cfs_0m",sep=""),format="GTiff",overwrite=TRUE)
    append(vel_rast,vel_0_rast,after=(pos0-1))
  }
  vel_rast <- brick(lapply(vel_rast,function(b) raster(x=paste(tempwd,"velocity","/",b,sep=""))))
  
  temp_list <- list()
  temp_list$depth_rast <- depth_rast
  temp_list$vel_rast <- vel_rast
  temp_list$modeled_q <- modeled_q

  return(temp_list)
} # end of function