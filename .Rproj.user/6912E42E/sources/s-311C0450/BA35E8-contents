# This script will house the processing options and functionality
# This script will produce area-lookup tables by species
# Last edited by Elaina Passero on 10/22/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis",
              "ggplot2","data.table","dplyr","plotly","spex","stars","igraph","deldir","hydroTSM")
#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)

### Begin Inputs ###

## Primary Inputs
wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/" # Project working directory
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)
hab_mets <- list("depth","velocity") #Variables from iRIC calculation result used for habitat analysis
species_list <- c("longfindace","yellowbullhead")#"desertsucker","sonoransucker","redshiner","roundtailchub","greensunfish","fatheadminnow","speckleddace")
species <- "longfindace"
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
reach_name <- "Cherry_Braid" # Should match name of folder with results
dis_unit <- "cms" #units of discharge

## Secondary Inputs - Use only if switching between projects
Check0Flow <- "Yes" # Yes- Calculate max area for 0-flow scenario and interpolate below min modeled Q

# Yes- external rasters or No- rasterize iRIC results. Inputs required if No.
LoadExternal <- "Yes"; if(LoadExternal=="No"){
  skip_num <- 2 # number of rows to skip when reading in raw outputs
  x_loc <- "X" # field name of X coordinate in model outputs
  y_loc <- "Y" # field name of y coordinate in model outputs
  dem <- "VerdeBeasley1Elev.tif" # Name of dem: VerdeBeasley1Elev.tif, smrf_dem_v241.tif, braidallpts_dem.tif, GilaMGnd.tif
  # Does the resolution of the rasters need to be manually set? If No, dem resolution will be used.
  setRes <- "No"; if(setRes=="Yes"){
    res <- c(1,1)} # resolution of rasters if they need to be manually set
  if(Check0Flow=="Yes"){ 
    depth0Flow <- "d_cfs_0m" # raster name for 0 flow depth
  }# end of internal rasterization inputs;
}

## Options - If set to No, inputs are not required for option
# Yes or No. Choose whether or not to check substrate conditions as part of suitable habitat
CheckSub <- "Yes"; if(CheckSub=="Yes"){
  sub_name <- "sub_dissolve" # shapefile name with no extension BeasleyUS_SedThiessenPoly1Dissolved
  sub_field <- "substrate"} # name of field in substrate map containing substrate type info; ParticalSi or substrate

# Yes or No. Choose whether or not to remove isolated (single cell) habitat patches
RemoveIslands <- "Yes"; if(RemoveIslands=="Yes"){
  island_size <- 2} # number of raster cells that is considered too small of a habitat patch

# Yes or No. Choose whether or not to normalize habitat area by reach length
NormalizeByL <- "Yes"; if(NormalizeByL=="Yes"){
  reach_length <- 0.61
  length_unit <- "km"}


### Begin Processing ###
reach_wd <- paste(wd,"reaches","/",reach_name,"/",sep = "")

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
  rm(delim_list)} else{
    
    ## Load in external rasterBricks and discharges
    source("load.cherry.R")
    out_val_rast <- load.cherry(reach_wd,Check0Flow)
    names(out_val_rast)<-c(hab_mets,"modeled_q")
    modeled_q <- out_val_rast$modeled_q
    out_val_rast[length(out_val_rast)]<-NULL
  }

## Load substrate
if(CheckSub == "Yes"){
  base_rast <- out_val_rast[[1]][[1]] # will be overwritten during rasterization - provides setup
  sub_map <- readOGR(dsn=paste(wd,"reaches", "/", reach_name, sep=""),layer=sub_name) # read in substrate shapefile
  sub_map_rast <- rasterize(sub_map,base_rast,field=sub_map@data[[sub_field]],update=TRUE)
}

##### Run for all species #####
outputs <- list()
outputs <- lapply(species_list, function(species){ # builds tables and maps for all species in list
  
  ## Reclassify Bricks with hydraulic and substrate HSC by lifestage
  source("find.hsc.R"); source("bricks.rc.R"); source("by.substrate.R"); source("find.sub.R"); source("remove.islands.R")
  
  hsc_all_spec <- fread(paste(reach_wd,"habitat_info","/",reach_name,"_hsc",".csv",sep = ""), 
                        header=TRUE, sep=",",data.table = FALSE)
  hsc_all_ages <- find.hsc(hsc_all_spec,species) # extract HSC for single species
  good_hab_list <- lapply(lifestages, function(a) bricks.rc(a,out_val_rast,hsc_all_ages,hab_mets))
  names(good_hab_list) <- lifestages # list of Bricks by lifestage
  
  # Not sure if this is working correctly yet
  if(CheckSub == "Yes"){
    sub_all_spec <- fread(paste(reach_wd,"habitat_info","/",reach_name,"_substrate",".csv",sep=""),
                          header=TRUE, sep = ",",data.table = FALSE) # load substrate requirements
    sub_all_ages <- find.sub(sub_all_spec,species) # extract substrate requirements for single species
    good_hab_list <- lapply(lifestages, function(a) by.substrate(a, good_hab_list, sub_all_ages,sub_map_rast))
    names(good_hab_list) <- lifestages
  } # end of if statement
  
  if(RemoveIslands == "Yes"){
    good_hab_list <- lapply(lifestages, function(a) remove.islands(a,good_hab_list,RemoveIslands,island_size))
    names(good_hab_list) <- lifestages
  }
  
  ## Total available habitat area by lifestage
  source("total.area.R")
  area_look_tab <- lapply(lifestages, function(a) total.area(a,good_hab_list,modeled_q,NormalizeByL,reach_length,hab_mets))
  names(area_look_tab) <- lifestages
  
  ## Order rasters of total available habitat by modeled discharge
  source("order.by.q.R")
  rast_by_q <- lapply(lifestages, function(a) order.by.q(a,good_hab_list,modeled_q))
  names(rast_by_q) <- lifestages
    
  # condense outputs into a single list
  outputs$area_look_tab <- area_look_tab
  outputs$rast_by_q <- rast_by_q
    
  return(outputs)
}) # end of species list function

names(outputs) <- species_list
list.save(outputs,file=paste(reach_wd,reach_name,"_fish_outputs.rdata",sep=""))

# Put tables in a nice format
tables <- lapply(species_list, function(species){
  outputs[[species]]$area_look_tab
})
names(tables) <- species_list


## Generate plots of area by discharge for all species
plottable <- data.frame(tables[[1]]$adult$discharge)
for(i in 1:length(tables)){
  plottable[,i+1] <- tables[[i]]$adult$normalized_area
  #plottable[,i+1] <- tables[[i]]$adult$total_area
}
colnames(plottable) <- c("discharge",species_list)

plot_ly(plottable,x=~discharge) %>%
  add_lines(y=plottable[,2],name=names(plottable[2]),line=list(color='black')) %>%
  add_lines(y=plottable[,3],name=names(plottable[3]),line=list(color='orange')) %>%
  # add_lines(y=plottable[,4],name=names(plottable[4]),line=list(color='teal')) %>%
  # add_lines(y=plottable[,5],name=names(plottable[5]),line=list(color='blue')) %>%
  # add_lines(y=plottable[,6],name=names(plottable[6]),line=list(color='red')) %>%
  # add_lines(y=plottable[,7],name=names(plottable[7]),line=list(color='yellow')) %>%
  # add_lines(y=plottable[,8],name=names(plottable[8]),line=list(color='green')) %>%
  # add_lines(y=plottable[,9],name=names(plottable[9]),line=list(color='purple')) %>%
  # add_lines(y=plottable[,10],name=names(plottable[10]),line=list(color='pink')) %>%
  layout(title="Habitat-discharge for Braided site w/ Substrate w/o LWD",xaxis=list(title="Discharge (cfs)"),yaxis=list(title="Normalized Habitat Area m2/km"))





