# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 02/13/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2","data.table")
require(packages)
lapply(packages,require,character.only=TRUE)

# Set Inputs
wd <- "C:\\Users\\epassero\\Desktop\\VRDSS\\verde-refdss\\" # Set path to local repository
habMets <- list("Depth","VelocityMag") #Variables from iRIC calculation result used for habitat analysis
species <- "fakefish"
lifestages <- list("adult","juvenile") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "1Beasley"
DEM <- "VerdeBeasley1Elev.tif" # Name of DEM used in iRIC

# Load functions
source(paste(wd,"iric.process.smr.R",sep="\\"))
source(paste(wd, "stacks.rc.R",sep="\\"))

# Run functions
## Convert iRIC outputs to rasterStacks by variable
iricValRast <- list()
for(a in 1:length(habMets)) {
  iricValRast[[a]] <- list(paste(habMets[[a]]))
  inMet <- habMets[[a]]
  iricValRast[[a]] <- stack(iric.process.smr(wd,inMet,DEM,reachName))
}
names(iricValRast) <-habMets #name Stacks by their variable

## Reclassify Stacks with hydraulic HSC by lifestage
hsc_allages<-fread(paste(wd,species,"_hsc",".csv",sep = ""), header=TRUE, sep=",")
hydHabList <- list() # list that will hold suitable hydraulic habitat by lifestage
for(b in 1:length(lifestages)){
  hsc <- hsc_allages[b] # creates HSC table for current lifestage
  hydHabList[[b]] <- stacks.rc(iricValRast,hsc,habMets)
}
names(hydHabList) <- lifestages # list of Bricks by lifestage


