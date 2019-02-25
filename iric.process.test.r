# Adapted from IRIC_processing_v1 by Julian Scott 01/30/19
# Function: Processes iRIC output by discharge and variable. Returns list of rasters. 
# Last edited by Elaina Passero on 02/21/19

iric.process.smr <- function(wd,inMet,DEM,reachName,csvList) {
  setwd(paste(wd,"results","\\",reachName,"\\",sep = "")) # DEM and iRIC calculation results must be in their own folder
  
  # read in elevation surface from the working directory
  SMR_elev <- raster(DEM)
  # create an empty raster with the extent, resolution, and projection of the DEM.
  e <- extent(SMR_elev)
  res <- res(SMR_elev)
  setCRS <- crs(SMR_elev)
  r <- raster(x = e,resolution = res,crs = setCRS)
  # Create empty stack to contain rasters
  SMR_Q_S <- stack()
  
  # Variables that will define the values of the processed iric result grid
  val = inMet
  
  # Transfer values from iric output i to the cells of raster r, but only when the cell is inundated (!= 0)
  # If multiple points from the iric output are within a cell of r, the mean points is used for the cell value.
  SMR_Q_S <- lapply(csvList,function(i) rasterize(x = i[,c("X","Y")],y = r, field = ifelse(i[,"Depth"] == 0,NA,i[,val]),fun = mean))
  
  # set projection of raster i
  proj4string(SMR_Q_S) <- setCRS
  # Resample raster i using bilinear interpolation to fill in those cells in r_i that did not have a cell value due to no point overlap
  SMR_Q_S <- raster::projectRaster(from=SMR_Q_S,to=SMR_elev,method = 'bilinear')
 
   # Returns list of rasters
  return(SMR_Q_S)
} # end function