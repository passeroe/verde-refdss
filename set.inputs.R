# This document houses all of the inputs for fish_hab_master.R
# Last updated by Elaina Passero on 5/16/19

# Primary Inputs
wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/"
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
#setwd(wd)
habMets <- list("depth","velocity") #Variables from calculation result used for habitat analysis. Case sensistive!
species <- "speckleddace" # can take a list or a single species
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Cherry_Braid" # Should match name of folder with results
DEM <- "braidallpts_DEM.tif" # DEM used in grid: VerdeBeasley1Elev.tif; smrf_DEM_v241.tif; braidallpts_DEM.tif. If loading externally put NA
disunit <- "cfs" #units of discharge
subName <- "sub_dissolve" # Name of substrate shapefile w/out extension

# Optional Settings
CheckSub <- "Yes" # Yes or No. Choose whether or not to check substrate conditions as part of suitable habitat
LoadExternal <- "Yes" # Yes- external rasters or No- rasterize iRIC results.
RemoveIslands <- "Yes" # Yes or No. Choose whether or not to remove isolated (<= 2 cells) habitat patches
NormalizeByL <- "Yes" # Yes or No. Choose whether or not to normalize habitat area by reach length
reachL <- 0.61 # supply reach length if normalizing by length - if not set equal to 1

# Secondary Inputs - Change only if switching between projects
skipnum <- 1 # number of rows to skip when reading in CSV results - Do not skip headers
setRes <- "No" # Does the resolution need to be manually set?
res <- c(0.25,0.25) # resolution of rasterized results if they need to be manually set
xLoc <- "x" # field name of X coordinate in CSVs - Case sensitive
yLoc <- "y" # field name of y coordinate in CSVs - Case sensitive


# Do not change unless adding a variable
inputs <- list(c(wd,habMets,species,lifestages,reachName,DEM,disunit,subName,
                 CheckSub,LoadExternal,RemoveIslands,NormalizeByL,reachL,
                 skipnum,setRes,res,xLoc,yLoc))