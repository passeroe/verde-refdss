# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 03/25/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2","data.table","dpylr","plotly")
#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)

# Set Inputs
wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/"
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)
habMets <- list("Depth","Velocity..magnitude.") #Variables from iRIC calculation result used for habitat analysis
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Sample" # 1Beasley or Sample
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC: VerdeBeasley1Elev.tif or smrf_DEM_v241.tif
disunit <- "cms" #units of discharge

# Options: Currently this is only set up to run with the Sample reach
CheckSub <- 1 # 1 (Yes) or 0 (No). Choose whether or not to check substrate conditions as part of suitable habitat
CalcEffArea <- 1 # 1 (Yes) or 0 (No). Choose whether or not to calculate effective habitat area

# Load functions
source("get.results.R")
source("iric.process.smr.R")
source("bricks.rc.R")
source("by.substrate.R")
source("brick.2.spdf.R")
source("effective.area.R")
source("build.tables.eff.R")
source("save.polys.eff.R")
source("build.tables.tot.R")
source("save.polys.tot.R")
source("inspect.hydro.R")
source("interp.table.R")
source("interp.plot.R")

# Run functions
## Format result CSVs and get list of discharges
holdList <- get.results(wd,reachName,disunit)
csvList <- holdList$csvList
modeled_q <- holdList$modeled_q
rm(holdList)

## Convert iRIC outputs to rasterBricks by variable
iricValRast <- list()
iricValRast <- lapply(habMets, function(a) iric.process.smr(a,csvList,wd,DEM,reachName))
names(iricValRast) <-habMets
rm(csvList)

## Reclassify Bricks with hydraulic and substrate HSC by lifestage
hsc_allages<-fread(paste(wd,species,"_hsc",".csv",sep = ""), header=TRUE, sep=",")
if(CheckSub == "1"){sub_allages<-fread(paste(wd,species,"_substrate",".csv",sep=""),header=TRUE, sep = ",",data.table = FALSE)} # load substrate requirements
goodHabList <- list() # list that will hold suitable hydraulic habitat by lifestage
for(b in 1:length(lifestages)){
  hsc <- hsc_allages[b] # creates HSC table for current lifestage
  goodHabList[[b]] <- bricks.rc(iricValRast,hsc,habMets)
  if(CheckSub == "1"){
    subTab <- sub_allages[,b] # creates table of substrate for current lifestage
    hhList <- goodHabList[[b]] # holds rasters of area for current lifestage
    goodHabList[[b]] <- by.substrate(hhList,subTab)
  } # end of if statement
} # end of for loop
names(goodHabList) <- lifestages # list of Bricks by lifestage

## Total available habitat area by lifestage
goodPolyList <- lapply(goodHabList, function(c) brick.2.spdf(c))
rm(goodHabList)

## Effective habitat area
if (CalcEffArea == 1){
  ### Calculate effective habitat area
  effAreaList <- lapply(lifestages,function(e) effective.area(e,goodPolyList))
  names(effAreaList) <- lifestages
  ### Construct Area-Lookup Tables
  areaLookTab <- lapply(lifestages, function(j) build.tables.eff(j,goodPolyList,effAreaList,modeled_q)) # data frame of total available and effective area
  names(areaLookTab) <- lifestages
  polyTab <- lapply(lifestages, function(m) save.polys.eff(m, goodPolyList, effAreaList, modeled_q))# data frame of spatial polygons
  names(polyTab) <- lifestages
} else{ ## Total available habitat area
  ### Construct Area-Lookup Tables
  areaLookTab <- lapply(lifestages, function(p) build.tables.tot(p,goodPolyList,totAreaList,modeled_q)) # data frame of total available area
  names(areaLookTab) <- lifestages
  polyTab <- lapply(lifestages, function(r) save.polys.tot(r, goodPolyList, effAreaList, modeled_q)) # data frame of spatial polygons
  names(polyTab) <- lifestages
}

## Read in hydrograph
hydrograph <- fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE)
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

## Inspect Area-discharge relationships before interpolating
#inspect.plot <- lapply(lifestages, function(s) inspect.hydro(s,hydrograph,areaLookTab))

## Generate Interpolated Discharge-Area Lookup Tables from Hydrograph and Regression
### Currently, this table does not contain interpolated values
inter.Tab <- lapply(lifestages, function(t) interp.table(t,hydrograph,areaLookTab))
inter.plots <- lapply(lifestages, function(t) interp.plot(t,inter.Tab))
