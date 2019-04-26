# Adapted from IRIC_processing_v1 by Julian Scott 01/30/19
# Function: Processes iRIC output by discharge and variable. Returns list of rasters. 
# Last edited by Elaina Passero on 04/26/19

iric.process.smr <- function(a,csvList,wd,DEM,reachName) {
  # read in elevation surface from the working directory
  SMR_elev <- raster(paste(wd,"results","/",reachName,"/",DEM,sep = ""))
  # create an empty raster with the extent, resolution, and projection of the DEM.
  e <- extent(SMR_elev)
  res <- res(SMR_elev)
  #res <- c(1.5,1.5)
  setCRS <- crs(SMR_elev)
  r <- raster(x = e,resolution = res,crs = setCRS)
  
  # Transfer values from iric output i to the cells of raster r, but only when the cell is inundated (!= 0)
  # If multiple points from the iric output are within a cell of r, the mean points is used for the cell value.
  depth <- grep("depth",names(csvList[[1]]),ignore.case = TRUE,value = TRUE)
  SMR_Q_S <- stack(lapply(csvList,function(i) rasterize(x = i[,c("X","Y")],y = r, field = ifelse(i[,depth] == 0,NA,i[,a]),fun = mean)))
  proj4string(SMR_Q_S) <- setCRS
  # Resample raster i using bilinear interpolation to fill in those cells in r_i that did not have a cell value due to no point overlap
  SMR_Q_S <- raster::projectRaster(from=SMR_Q_S,to=SMR_elev,method = 'bilinear')
  # Returns Brick of rasters
  return(SMR_Q_S)
} # end function


