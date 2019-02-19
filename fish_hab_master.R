# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 02/19/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2","data.table")
require(packages)
lapply(packages,require,character.only=TRUE)

# Set Inputs
wd <- "C:\\Users\\epassero\\Desktop\\VRDSS\\verde-refdss\\" # Set path to local repository
habMets <- list("Depth","VelocityMag") #Variables from iRIC calculation result used for habitat analysis
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Sample" # 1Beasley or Sample
DEM <- "smrf_DEM_v241.tif" # Name of DEM used in iRIC: VerdeBeasley1Elev.tif or smrf_DEM_v241.tif

# Options: Currently this is only set up to run with the Sample reach
CheckSub <- 1 # 1 (Yes) or 0 (No). Choose whether or not to check substrate conditions as part of suitable habitat

# Load functions
source(paste(wd,"iric.process.smr.R",sep="\\"))
source(paste(wd, "stacks.rc.R",sep="\\"))
source(paste(wd, "by.substrate.R",sep="\\"))

# Run functions
## Convert iRIC outputs to rasterStacks by variable
iricValRast <- list()
for(a in 1:length(habMets)) {
  iricValRast[[a]] <- list(paste(habMets[[a]]))
  inMet <- habMets[[a]]
  iricValRast[[a]] <- stack(iric.process.smr(wd,inMet,DEM,reachName))
} # end of for loop
names(iricValRast) <-habMets #name Stacks by their variable

## Reclassify Stacks with hydraulic and substrate HSC by lifestage
hsc_allages<-fread(paste(wd,species,"_hsc",".csv",sep = ""), header=TRUE, sep=",")
if(CheckSub == "1"){sub_allages<-fread(paste(wd,species,"_substrate",".csv",sep=""),header=TRUE, sep = ",",data.table = FALSE)} # load substrate requirements
hydHabList <- list() # list that will hold suitable hydraulic habitat by lifestage
for(b in 1:length(lifestages)){
  hsc <- hsc_allages[b] # creates HSC table for current lifestage
  hydHabList[[b]] <- stacks.rc(iricValRast,hsc,habMets)
  if(CheckSub == "1"){
    subTab <- sub_allages[,b] # creates table of substrate for current lifestage
    hhList <- hydHabList[[b]] # holds rasters of area for current lifestage
    hydHabList[[b]] <- by.substrate(hhList,subTab)
  } # end of if statement
} # end of for loop
names(hydHabList) <- lifestages # list of Bricks by lifestage



