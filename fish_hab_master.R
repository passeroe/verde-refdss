# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 04/26/19

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
habMets <- list("Depth","Velocity") #Variables from iRIC calculation result used for habitat analysis ex: Velocity..magnitude.
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Sample" # Should match name of folder with results
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC: VerdeBeasley1Elev.tif or smrf_DEM_v241.tif or braidallpts_DEM.tif. If loading externally put NA
disunit <- "cms" #units of discharge
reachL <- 0.61

# Options: Do not use CheckSub right now
CheckSub <- 0 # 1 (Yes) or 0 (No). Choose whether or not to check substrate conditions as part of suitable habitat
LoadExternal <- 0 # 1 (Yes; external rasters) or 0 (No; iRIC results). Choose whether to process externally produced raster files
# or to rasterize iRIC results.
RemoveIslands <- 1 # 1 (Yes) or 0 (No). Choose whether or not to remove isolated (single cell) habitat patches
NormalizeByL <- 0 # 1 (Yes) or 0 (No). Choose whether or not to normalize habitat area by reach length

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
source("find.hsc.R"); source("bricks.rc.R"); source("by.substrate.R"); source("find.sub.R")

hsc_allspec<-fread(paste(wd,reachName,"_hsc",".csv",sep = ""), header=TRUE, sep=",",data.table = FALSE)
hsc_allages <- find.hsc(hsc_allspec,species) # extract HSC for single species
goodHabList <- lapply(lifestages, function(b) bricks.rc(b,outValRast,hsc_allages,habMets))
names(goodHabList) <- lifestages # list of Bricks by lifestage

# Not sure if this is working correctly yet
if(CheckSub == "1"){
  sub_allspec <- fread(paste(wd,reachName,"_substrate",".csv",sep=""),header=TRUE, sep = ",",data.table = FALSE) # load substrate requirements
  sub_allages <- find.sub(sub_allspec,species) # extract substrate requirements for single species
  goodHabList <- lapply(lifestages, function(b) by.substrate(b, goodHabList, sub_allages))
  names(goodHabList) <- lifestages
  } # end of if statement

## Total available habitat area by lifestage
source("total.area.R")
areaLookTab <- lapply(lifestages, function(c) total.area(c,goodHabList,modeled_q,RemoveIslands,NormalizeByL,reachL))
names(areaLookTab) <- lifestages

## Order rasters of total available habitat by modeled discharge
source("rast.by.q.R")
rastByQ <- lapply(lifestages, function(c) rast.by.q(c,goodHabList,modeled_q))
names(rastByQ) <- lifestages

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

## Simple plots of Cherry Creek Results 
plot(x=areaLookTab[[1]]$discharge,y=areaLookTab[[1]]$normalizedArea, type="l",xlim=c(0,200),ylim=c(0,12000),ann=FALSE)
title(main="Habitat-discharge for Braided site w/o LWD for Longfin Dace",xlab="Normalized Area",ylab="Discharge")
plot(x=areaLookTab[[1]]$discharge,y=areaLookTab[[1]]$normalizedArea, type="l",xlim=c(0,10000),ylim=c(0,12000),ann=FALSE)
title(main="Habitat-discharge for Braided site w/o LWD for Longfin Dace All Q",xlab="Normalized Area",ylab="Discharge")

