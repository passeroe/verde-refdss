# Adapted from IRIC_processing_v1 by Julian Scott 01/30/19
# Function: Processes iRIC output by discharge and variable. Returns list of rasters. 
# Last edited by Elaina Passero on 02/03/19


# Requirements for running this code:

# 1. This code uses iric output using Calculation Result -> Export > 2D -> Format = CSV files
# 2. The sequential layers of inundating discharge surfaces has an order that is inherited when it is read in from the directory.
#    Therefore, the naming convention of the IRIC output csv files must be such that they are ordered correctly 
#    E.g., when viewing the csvs in File Explorer, when the folder is sorted by name, are they in the correct ascending order?
#    We achieve this using the following convention, IRICoutput_0000.01, IRICoutput_0001.5, IRICoutput_0010.0,IRICoutput_1010.0, etc
#    There are many other ways to do this, but this is how the code we have written works. 
# 3. change setwd to the IRIC_Processing_in_R_v1 folder to run this code with the example
# 4. When ready to use on your own dataset, there are multiple things that will have to be changed
#   - coordinate projection system (crs)
#   - directories
#   - etc

# This is version 1 and is a work in progress. Please keep in touch with developments as you use this or other code for processing iric data.

#  packages used
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2")

#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)

##### Begin Function #####
iric.process.smr <- function(wd,inMet,DEM,reachName) {

# Set this to the IRIC_Processing_in_R_v1 folder to run this code
setwd(paste(wd,"results","\\",reachName,"\\",sep = "")) # DEM and iRIC calculation results must be in their own folder

# read in elevation surface from the working directory
SMR_elev <- raster(DEM)
#plot(SMR_elev)

# get names of iric output csv files in the working directory
iric_results <- list.files(pattern = ".csv") # working directory cannot contain any csv's besides results

# create an empty raster with the extent, resolution, and projection of the DEM.
e <- extent(SMR_elev)
res <- res(SMR_elev)
setCRS <- crs(SMR_elev)
r <- raster(x = e,resolution = res,crs = setCRS)

# read in one of the result files to view head and QAQC
read.csv(iric_results[1],skip = 2,header = T) %>%
  head()

# Variables that will define the values of the processed iric result grid
val = inMet

# Create empty list to contain rasters
SMR_Q_l <- list()
# Create empty vector to contain modeled Qs
modeled_q <- c()
    
# For every iric output file (csv) in iric_results, 
for (i in iric_results) {
# get iric output i
df_i <-  read.csv(i,skip = 2,header = T)
# set names 15 & 21 for Sample and 12 & 15 for Chris's
df_i <- setnames(df_i,c(15,21),c("VelocityMag","ShearSMag")) # remove spaces from habitat variable names; need to work out kinks in results
# set the discharge of iric output i as q_i [character]
q_i <- sub("Result_","",sub(".csv","",i))
# Transfer values from iric output i to the cells of raster r, but only when the cell is inundated (!= 0)
# If multiple points from the iric output are within a cell of r, the mean points is used for the cell value.
r_i <- rasterize(x = df_i[,c("X","Y")],y = r, field = ifelse(df_i[,"Depth"] == 0,NA,df_i[,val]),fun = mean)
# set projection of raster i
proj4string(r_i) <- setCRS
# Resample raster i using bilinear interpolation to fill in those cells in r_i that did not have a cell value due to no point overlap
r_rsmpl_i <- raster::projectRaster(from=r_i,to=SMR_elev,method = 'bilinear')
# update the name of the resampled raster to include the units of the discharge measure
names(r_rsmpl_i) <- paste0("cms",q_i)
# add resampled raster to the list
SMR_Q_l[[i]] <- r_rsmpl_i
# Create vector modeled qs
modeled_q <- c(modeled_q,as.numeric(q_i))
}
# Returns list of rasters
return(SMR_Q_l)

} # end function

