# This script will house the post-processing options and functionality
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
###########################################

# User inputs
wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/" # Project working directory
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)
species_list <-  "yellowbullhead"  #species of interest
reach_name <- "Cherry_Braid" # Should match name of folder with results
lifestages <- "adult"

# Yes or No. Choose whether or not to normalize habitat area by reach length
NormalizeByL <- "Yes"; if(NormalizeByL=="Yes"){
  reach_length <- 0.61
  length_unit <- "km"}

# Yes or No. Choose whether or not to calculate X-day statistics. Must supply number of days.
CalcXDayStats <- "Yes"; if(CalcXDayStats=="Yes"){
  x_days <- 10} # number of days for moving discharge and area statistics

# Yes or No. Yes - limit analysis to supplied dates. No - consider entire hydrograph.
DateRange <- "No"; if(DateRange=="Yes"){
  start_date <- "1993-10-01" # "YYYY-MM-DD"
  end_date <- "1994-03-30"} # "YYYY-MM-DD"

# Begin post-processing ###############################

reach_wd <- paste(wd,"reaches","/",reach_name,"/",sep = "")
output_name <- load(file=paste(reach_wd,reach_name,"_fish_outputs.rdata",sep="")) # load fish outputs
eval(parse(text=paste("fish_outputs=",output_name)))

## Read in hydrograph if one is supplied
hydrograph <- na.omit(fread(paste(reach_wd,"flow_scenarios","/",reach_name,"_hydrograph",".csv",sep=""),
                            header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")
if(DateRange=="Yes"){
  hydrograph <- subset(hydrograph, date > as.Date(start_date)) 
  hydrograph <- subset(hydrograph, date < as.Date(end_date))
}

post_outputs <- list()
post_outputs <- lapply(species_list, function(species){ 
  one_spec <- fish_outputs[[species]]
  for(i in 1:length(one_spec)){ # extracts the outputs by species into their own object
    tempobj = one_spec[[i]]
    eval(parse(text=paste(names(one_spec)[[i]],"=tempobj")))
  }

  # Flow-Scenario related scripts
  source("interp.table.R")
  inter_tab <- lapply(lifestages, function(a) interp.table(a,hydrograph,area_look_tab,NormalizeByL))
  names(inter_tab) <- lifestages
  post_outputs$inter_tab <- inter_tab
  
  ## Generate Data Frames of moving X-Day area and discharge statistics
  if(CalcXDayStats=="Yes"){
    source("x.day.stats.R")
    x_day_stats <- lapply(lifestages, function(a) x.day.stats(a,inter_tab,x_days,NormalizeByL,reach_length))
    names(x_day_stats) <- lifestages
    post_outputs$x_day_stats <- x_day_stats
  }
  
  source("avg.month.area.R")
  avg_monthly_area <- lapply(lifestages, function(a) avg.month.area(a,inter_tab,NormalizeByL))
  names(avg_monthly_area) <- lifestages
  post_outputs$avg_monthly_area <- avg_monthly_area
  # end of flow scenario dependent processes
  
  return(post_outputs)
  })
names(post_outputs) <- species_list


## Generate and view plots of total area through the hydrograph
source("interp.plot.R")
interPlots <- lapply(lifestages, function(a) interp.plot(a,inter_tab,NormalizeByL))
head(interPlots)
