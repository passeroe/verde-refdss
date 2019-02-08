# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 02/08/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2","data.table")
require(packages)
lapply(packages,require,character.only=TRUE)

# Set file locations
wd <- "C:\\Users\\epassero\\Desktop\\VRDSS\\verde-refdss" # Set path to local repository

# Load functions
source(paste(wd,"iric.process.smr.R",sep="\\"))
source(paste(wd, "stacks.rc.R",sep="\\"))

# Set inputs
habMets = list("Depth","VelocityMag") #Variables from iRIC calculation result used for habitat analysis
species = "fakefish"

# Run functions
## Convert iRIC outputs to rasterStacks by variable
iricValRast <- list()
for(a in 1:length(habMets)) {
  iricValRast[[a]] <- list(paste(habMets[[a]]))
  inMet <- habMets[[a]]
  iricValRast[[a]] <- stack(iric.process.smr(wd,inMet))
}
names(iricValRast) <-habMets #name Stacks by their variable

## Reclassify Stacks by HSC
hsc<-fread(paste(wd,species,"_hsc",".csv",sep = ""), header=TRUE, sep=",")
acceptRast <- stacks.rc(iricValRast,hsc,habMets)
plot(acceptRast)

