# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 04/12/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis",
              "ggplot2","data.table","dplyr","plotly","spex","stars","igraph")
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
species <- "browntrout"
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Cherry_Gage" # 1Beasley or Sample or Delaware_1
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC: VerdeBeasley1Elev.tif or smrf_DEM_v241.tif. If loading externally put NA
disunit <- "cms" #units of discharge

# Options: Currently this is only set up to run with the Sample reach
CheckSub <- 0 # 1 (Yes) or 0 (No). Choose whether or not to check substrate conditions as part of suitable habitat
CalcEffArea <- 0 # 1 (Yes) or 0 (No). Choose whether or not to calculate effective habitat area
LoadExternal <- 1 # 1 (Yes; external rasters) or 0 (No; iRIC results). Choose whether to process externally produced raster files
# or to rasterize iRIC results.
RemoveIslands <- 0 # 1 (Yes) or 0 (No). Choose whether or not to remove isolated (single cell) habitat patches

if(LoadExternal == "0"){
## Format result CSVs and get list of discharges
source("get.results.R")
holdList <- get.results(wd,reachName,disunit)
csvList <- holdList$csvList
modeled_q <- holdList$modeled_q
rm(holdList)

## Convert iRIC outputs to rasterBricks by variable
source("iric.process.smr.R")
outValRast <- list()
outValRast <- lapply(habMets, function(a) iric.process.smr(a,csvList,wd,DEM,reachName))
names(outValRast) <-habMets
rm(csvList)} else{

## Load in external rasterBricks and discharges
source("load.delaware.R")
reachCode <- "del1"
outValRast <- load.delaware(wd,reachName,reachCode)
names(outValRast)<-c(habMets,"modeled_q")
modeled_q <- outValRast$modeled_q
outValRast[length(outValRast)]<-NULL
}

## Reclassify Bricks with hydraulic and substrate HSC by lifestage
source("bricks.rc.R")
source("by.substrate.R")
hsc_allages<-fread(paste(wd,species,"_hsc",".csv",sep = ""), header=TRUE, sep=",")
if(CheckSub == "1"){sub_allages<-fread(paste(wd,species,"_substrate",".csv",sep=""),header=TRUE, sep = ",",data.table = FALSE)} # load substrate requirements
goodHabList <- list() # list that will hold suitable hydraulic habitat by lifestage
for(b in 1:length(lifestages)){
  hsc <- hsc_allages[b] # creates HSC table for current lifestage
  goodHabList[[b]] <- bricks.rc(outValRast,hsc,habMets)
  if(CheckSub == "1"){
    subTab <- sub_allages[,b] # creates table of substrate for current lifestage
    hhList <- goodHabList[[b]] # holds rasters of area for current lifestage
    goodHabList[[b]] <- by.substrate(hhList,subTab)
  } # end of if statement
} # end of for loop
names(goodHabList) <- lifestages # list of Bricks by lifestage

## Total available habitat area by lifestage
source("total.area.R")
areaLookTab <- lapply(lifestages, function(c) total.area(c,goodHabList,modeled_q))

## Order rasters of total available habitat by modeled discharge
source("rast.by.q.R")
rastByQ <- lapply(lifestages, function(c) rast.by.q(c,goodHabList,modeled_q))

## Read in hydrograph
hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

## Generate Interpolated Discharge-Area Lookup Tables from Hydrograph and Regression
source("interp.table.R")
interTab <- lapply(lifestages, function(t) interp.table(t,hydrograph,areaLookTab))
names(interTab) <- lifestages

## Generate and view plots of total area through the hydrograph
source("interp.plot.R")
interPlots <- lapply(lifestages, function(t) interp.plot(t,interTab))
head(interPlots)
