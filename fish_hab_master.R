# Function: This script serves as the master script that controls which functions are run and what inputs are used for finding suitable fish habitat
#         It will later be converted to the script that controls the Shiny App.
# Last edited by Elaina Passero on 06/03/19

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
wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/"
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)
habMets <- list("Depth","Velocity") #Variables from iRIC calculation result used for habitat analysis ex: Velocity..magnitude.
specieslist <- c("longfindace") #,"yellowbullhead","desertsucker","sonoransucker","redshiner","roundtailchub","greensunfish","fatheadminnow","speckleddace")
species <- "longfindace"
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
reachName <- "Beasley1" # Should match name of folder with results
disunit <- "cms" #units of discharge

## Secondary Inputs - Use only if switching between projects
Check0Flow <- "No" # Yes- Calculate max area for 0-flow scenario and interpolate below min modeled Q

# Yes- external rasters or No- rasterize iRIC results. Inputs required if No.
LoadExternal <- "No"; if(LoadExternal=="No"){
  skipnum <- 2 # number of rows to skip when reading in CSV results
  xLoc <- "X" # field name of X coordinate in CSVs
  yLoc <- "Y" # field name of y coordinate in CSVs
  DEM <- "VerdeBeasley1Elev.tif" # Name of DEM: VerdeBeasley1Elev.tif, smrf_DEM_v241.tif, braidallpts_DEM.tif, GilaMGnd.tif
  # Does the resolution of the rasters need to be manually set? If No, DEM resolution will be used.
  setRes <- "No"; if(setRes=="Yes"){
    res <- c(10,10)} # resolution of rasters if they need to be manually set
  if(Check0Flow=="Yes"){ 
    depth0Flow <- "insert depth raster layer" 
  }# end of internal rasterization inputs;
}

## Options - If set to No, inputs are not required for option
# Yes or No. Choose whether or not to check substrate conditions as part of suitable habitat
CheckSub <- "Yes"; if(CheckSub=="Yes"){
  subName <- "BeasleyUS_SedThiessenPoly1Dissolved"}

# Yes or No. Choose whether or not to remove isolated (single cell) habitat patches
RemoveIslands <- "Yes"; if(RemoveIslands=="Yes"){
  islandSize <- 2} # number of raster cells that is considered too small of a habitat patch

# Yes or No. Choose whether or not to normalize habitat area by reach length
NormalizeByL <- "No"; if(NormalizeByL=="Yes"){
  reachL <- 0.61
  unitL <- "km"} # Reach length in km. If not normalizing set equal to 1.

# Yes or No. Will a hydrograph be supplied? If "No" CalcXDayStats and DateRange can be left blank.
FlowScenario <- "Yes"; if(FlowScenario=="Yes"){
 
   # Yes or No. Choose whether or not to calculate X-day statistics. Must supply number of days.
  CalcXDayStats <- "No"; if(CalcXDayStats=="Yes"){
    xDays <- 7} # number of days for moving discharge and area statistics
  
  # Yes or No. Yes - limit analysis to supplied dates. No - consider entire hydrograph.
  DateRange <- "No"; if(DateRange=="Yes"){
    startDate <- "1993-10-01" # "YYYY-MM-DD"
    endDate <- "1994-03-30"} # "YYYY-MM-DD"

} # End of flow scenario related options

### Begin Processing ###

if(LoadExternal == "No"){
## Format result CSVs and get list of discharges
source("get.results.R")
holdList <- get.results(wd,reachName,skipnum,disunit)
csvList <- holdList$csvList
modeled_q <- holdList$modeled_q
rm(holdList)

### for cherry Creek ###
#source("exp.shp.R")
#resultsPts <- lapply(habMets, function(a) exp.shp(a,csvList,wd,DEM,reachName,xLoc,yLoc))

## Convert iRIC outputs to rasterBricks by variable
source("iric.process.smr.R")
outValRast <- list()
outValRast <- lapply(habMets, function(m) iric.process.smr(m,csvList,wd,DEM,reachName,setRes,xLoc,yLoc))
names(outValRast) <-habMets
rm(csvList)} else{

## Load in external rasterBricks and discharges
source("load.cherry.R")
#reachCode <- "del1"
outValRast <- load.cherry(wd,reachName,reachCode)
names(outValRast)<-c(habMets,"modeled_q")
modeled_q <- outValRast$modeled_q
outValRast[length(outValRast)]<-NULL
}

## Read in hydrograph if one is supplied
if(FlowScenario == "Yes"){
  hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
  hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")
  if(DateRange=="Yes"){
    hydrograph <- subset(hydrograph, date > as.Date(startDate)) 
    hydrograph <- subset(hydrograph, date < as.Date(endDate))
  }
}

## Load substrate
if(CheckSub == "Yes"){
  baseRast <- outValRast[[1]][[1]] # will be overwritten during rasterization - provides setup
  subMap <- readOGR(dsn=paste(wd,"results","/",reachName,sep = ""),layer=subName) # read in substrate shapefile
  #rastSubMap <- rasterize(subMap,baseRast,field=subMap@data$substrate,update=TRUE)
  rastSubMap <- rasterize(subMap,baseRast,field=subMap@data$ParticalSi,update=TRUE)
}

##### Run for all species #####
outputs <- list()
outputs <- lapply(specieslist, function(species){ # builds tables and maps for all species in list
  
  ## Reclassify Bricks with hydraulic and substrate HSC by lifestage
  source("find.hsc.R"); source("bricks.rc.R"); source("by.substrate.R"); source("find.sub.R"); source("remove.islands.R")
  
  hsc_allspec<-fread(paste(wd,reachName,"_hsc",".csv",sep = ""), header=TRUE, sep=",",data.table = FALSE)
  hsc_allages <- find.hsc(hsc_allspec,species) # extract HSC for single species
  goodHabList <- lapply(lifestages, function(a) bricks.rc(a,outValRast,hsc_allages,habMets))
  names(goodHabList) <- lifestages # list of Bricks by lifestage
  
  # Not sure if this is working correctly yet
  if(CheckSub == "Yes"){
    sub_allspec <- fread(paste(wd,reachName,"_substrate",".csv",sep=""),header=TRUE, sep = ",",data.table = FALSE) # load substrate requirements
    sub_allages <- find.sub(sub_allspec,species) # extract substrate requirements for single species
    goodHabList <- lapply(lifestages, function(a) by.substrate(a, goodHabList, sub_allages,rastSubMap))
    names(goodHabList) <- lifestages
    } # end of if statement
  
  if(RemoveIslands == "Yes"){
    goodHabList <- lapply(lifestages, function(a) remove.islands(a,goodHabList,RemoveIslands,islandSize))
    names(goodHabList) <- lifestages
  }
  
  ## Total available habitat area by lifestage
  source("total.area.R")
  areaLookTab <- lapply(lifestages, function(a) total.area(a,goodHabList,modeled_q,NormalizeByL,reachL,habMets))
  names(areaLookTab) <- lifestages
  
  ## Order rasters of total available habitat by modeled discharge
  source("rast.by.q.R")
  rastByQ <- lapply(lifestages, function(a) rast.by.q(a,goodHabList,modeled_q))
  names(rastByQ) <- lifestages
  
  ## Generate Interpolated Discharge-Area Lookup Tables from Hydrograph and Regression if hydrograph provided
  if(FlowScenario=="Yes"){
    source("interp.table.R")
    interTab <- lapply(lifestages, function(a) interp.table(a,hydrograph,areaLookTab,NormalizeByL))
    names(interTab) <- lifestages
    
    ## Generate and view plots of total area through the hydrograph
    #source("interp.plot.R")
    #interPlots <- lapply(lifestages, function(a) interp.plot(a,interTab,NormalizeByL))
    #head(interPlots)
    
    ## Generate Data Frames of moving X-Day area and discharge statistics
    if(CalcXDayStats=="Yes"){
      source("x.day.stats.R")
      xDayStats <- lapply(lifestages, function(a) x.day.stats(a,interTab,xDays))
      names(xDayStats) <- lifestages
    }
    
    source("avg.month.area.R")
    avgMonthlyArea <- lapply(lifestages, function(a) avg.month.area(a,interTab,NormalizeByL))
    names(avgMonthlyArea) <- lifestages
    # end of flow scenario dependent processes
    
    # condense outputs into single list
    outputs$areaLookTab <- areaLookTab
    outputs$rastByQ <- rastByQ
    outputs$avgMonthlyArea <- avgMonthlyArea
    
    
  } else{ # outputs not including any flow-scenario related outputs
    # condense outputs into a single list
    outputs$areaLookTab <- areaLookTab
    outputs$rastByQ <- rastByQ
  }
  return(outputs)
  }) # end of species list function

names(outputs) <- specieslist

# Put tables in a nice format
tables <- lapply(specieslist, function(species){
  outputs[[species]]$areaLookTab
  })
names(tables) <- specieslist


## Generate plots of area by discharge for all species
plottable <- data.frame(tables[[1]]$adult$discharge)
for(i in 1:length(tables)){
  #plottable[,i+1] <- tables[[i]]$adult$normalizedArea
  plottable[,i+1] <- tables[[i]]$adult$totalArea
}
colnames(plottable) <- c("discharge",specieslist)

plot_ly(plottable,x=~discharge) %>%
  add_lines(y=plottable[,2],name=names(plottable[2]),line=list(color='black')) %>%
  add_lines(y=plottable[,3],name=names(plottable[3]),line=list(color='orange')) %>%
  add_lines(y=plottable[,4],name=names(plottable[4]),line=list(color='teal')) %>%
  add_lines(y=plottable[,5],name=names(plottable[5]),line=list(color='blue')) %>%
  add_lines(y=plottable[,6],name=names(plottable[6]),line=list(color='red')) %>%
  add_lines(y=plottable[,7],name=names(plottable[7]),line=list(color='yellow')) %>%
  add_lines(y=plottable[,8],name=names(plottable[8]),line=list(color='green')) %>%
  add_lines(y=plottable[,9],name=names(plottable[9]),line=list(color='purple')) %>%
  add_lines(y=plottable[,10],name=names(plottable[10]),line=list(color='pink')) %>%
  layout(title="Habitat-discharge for Braided site w/ Substrate w/o LWD",xaxis=list(title="Discharge (cfs)"),yaxis=list(title="Total Area m2"))
  
#writeRaster(outputs$greensunfish$rastByQ$adult,"gsf250.tif",format="GTiff")