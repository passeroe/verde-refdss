# This script will house the pre-processing options and functionality
# This script will process 2D hydraulic modeling results 
# This script will rasterize substrate maps if applicable
# Last edited by Elaina Passero on 10/29/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis",
              "ggplot2","data.table","dplyr","plotly","spex","stars","igraph","deldir","hydroTSM","rlist")
#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)

## Primary Inputs
#wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/" # Project working directory
wd <- 'C:/Users/Elaina/Desktop/verde-refdss/'
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)
hab_mets <- list("depth","velocity") #Variables from iRIC calculation result used for habitat analysis - case sensitive!
reach_name <- "Cherry_Braid" # Should match name of folder with results
dis_unit <- "cms" #units of discharge

# Yes- external rasters or No- rasterize iRIC results. Inputs required if No.
LoadExternal <- "No"; if(LoadExternal=="No"){
  skip_num <- 0 # number of rows to skip when reading in raw outputs
  x_loc <- "x" # field name of X coordinate in model outputs
  y_loc <- "y" # field name of y coordinate in model outputs
  dem <- "braidallpts_dem.tif" # Name of dem: VerdeBeasley1Elev.tif, smrf_dem_v241.tif, braidallpts_dem.tif, GilaMGnd.tif
  # Does the resolution of the rasters need to be manually set? If No, dem resolution will be used.
  setRes <- "No"; if(setRes=="Yes"){
    res <- c(1,1)} # resolution of rasters if they need to be manually set
}

## Options - If set to No, inputs are not required for option
# Yes or No. Choose whether or not to check substrate conditions as part of suitable habitat
CheckSub <- "Yes"; if(CheckSub=="Yes"){
  sub_name <- "sub_dissolve" # shapefile name with no extension BeasleyUS_SedThiessenPoly1Dissolved
  sub_field <- "substrate"} # name of field in substrate map containing substrate type info; ParticalSi or substrate


### Begin Processing ###
reach_wd <- paste(wd,"reaches","/",reach_name,"/",sep = "")
rasterOptions(overwrite = TRUE,tmpdir = paste(reach_wd,"temp/",sep=""))
pre_outputs <- list()

if(LoadExternal == "No"){
  ## Format result CSVs and get list of discharges
  source("get.results.R")
  temp_list <- get.results(reach_wd,skip_num,dis_unit)
  delim_list <- temp_list$delim_list
  modeled_q <- temp_list$modeled_q
  rm(temp_list)
  
  ## Convert iRIC outputs to rasterBricks by variable
  source("iric.process.smr.R")
  out_val_rast <- list()
  out_val_rast <- lapply(hab_mets, function(m) iric.process.smr(m,delim_list,reach_wd,dem,setRes,x_loc,y_loc))
  names(out_val_rast) <-hab_mets
  } else{
    
    ## Load in external rasterBricks and discharges
    source("load.cherry.R")
    out_val_rast <- load.cherry(reach_wd,Check0Flow)
    names(out_val_rast)<-c(hab_mets,"modeled_q")
    modeled_q <- out_val_rast$modeled_q
    out_val_rast[length(out_val_rast)]<-NULL
  }

pre_outputs$out_val_rast <- out_val_rast
pre_outputs$modeled_q <- modeled_q

## Load substrate
if(CheckSub == "Yes"){
  base_rast <- out_val_rast[[1]][[1]] # will be overwritten during rasterization - provides setup
  sub_map <- readOGR(dsn=paste(wd,"reaches", "/", reach_name, sep=""),layer=sub_name) # read in substrate shapefile
  sub_map_rast <- rasterize(sub_map,base_rast,field=sub_map@data[[sub_field]],update=TRUE)
  
  pre_outputs$sub_map_rast <- sub_map_rast
}

# save outputs for internal use
list.save(pre_outputs,file=paste(reach_wd,reach_name,"_pre_outputs.rdata",sep=""))





