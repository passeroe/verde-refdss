# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 03/12/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis","ggplot2","data.table","dpylr")
#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)

# Set Inputs
wd <- "C:\\Users\\epassero\\Desktop\\VRDSS\\verde-refdss\\" # Set path to local repository
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
source(paste(wd,"get.results.R",sep="\\"))
source(paste(wd,"iric.process.smr.R",sep="\\"))
source(paste(wd,"bricks.rc.R",sep="\\"))
source(paste(wd,"by.substrate.R",sep="\\"))
source(paste(wd,"brick.2.spdf.R",sep="\\"))
source(paste(wd,"effective.area.R",sep="\\"))
source(paste(wd,"build.tables.eff.R",sep="\\"))

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
  areaTabsEff <- lapply(lifestages, function(j) build.tables.eff(j,goodPolyList,effAreaList,modeled_q))
  polyTab <- areaTabsEff[[1]] # data frame of spatial polygons
  areaLookTab <- areaTabsEff[[2]] # data frame of total available and effective area
  rm(areaTabsEff)
}



