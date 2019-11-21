# This script will house the post-processing options and functionality
# Last edited by Elaina Passero on 11/18/19

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis",
              "ggplot2","data.table","dplyr","plotly","spex","stars","igraph","deldir","hydroTSM",
              "lubridate","rlist")
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

species_list <- list("longfindace","desertsucker")#"sonoransucker") # "yellowbullhead",,"redshiner","roundtailchub","greensunfish","fatheadminnow","speckleddace")
#species <- "longfindace"
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
reach_name <- "USBeasley1" # Should match name of folder with results
dis_unit <- "cms" #units of discharge

# Yes or No. Indicate whether or not to substrate was a condition of suitable habitat
CheckSub <- "Yes"

# Yes or No. Choose whether or not to normalize habitat area by reach length
NormalizeByL <- "No"; if(NormalizeByL=="Yes"){
  reach_length <- 0.61
  length_unit <- "km"}

# Yes or No. Choose whether or not to calculate X-day statistics. Must supply number of days.
CalcXDayStats <- "Yes"; if(CalcXDayStats=="Yes"){
  x_days <- 10} # number of days for moving discharge and area statistics

# Yes or No. Yes - limit analysis to supplied dates. No - consider entire hydrograph.
DateRange <- "No"; if(DateRange=="Yes"){
  start_date <- "1993-10-01" # "YYYY-MM-DD"
  end_date <- "1994-03-30"} # "YYYY-MM-DD"

# Yes or No. Yes - bring in flow scenarios for
LoadScenario <- "Yes"; if(LoadScenario == "Yes"){
  scene_names <- c("4_seasons_test")
}

CompareScenes <- "Yes"


# Begin post-processing #

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

# to convert from CFS to CMS
hydrograph <- hydrograph %>%
  mutate(discharge.cms = discharge*0.02832) %>%
  select(-discharge) %>%
  rename(discharge = discharge.cms)

# create list of flow scenario data frames

if(LoadScenario == "Yes"){
  scene_list <- lapply(scene_names, function(s){
    q_ts <- na.omit(fread(file=paste(reach_wd,"flow_scenarios","/",reach_name,"_",s,".csv",sep=""),
                          header=TRUE, sep = ",",data.table=FALSE)) %>%
      mutate(date_form = as.Date(date)) %>%
      select(-date) %>%
      rename(date = date_form)
    if(DateRange=="Yes"){
      q_ts <- subset(q_ts, date > as.Date(start_date)) 
      q_ts <- subset(q_ts, date < as.Date(end_date))
    }
    return(q_ts)
  })
  names(scene_list) <- scene_names
  scene_list$hydrograph <- hydrograph
} else{
  scene_list <- list(hydrograph)
}

# Fish post-processing
scene_fish_out <- list()
scene_fish_out <- lapply(scene_list, function(s){
  
  post_fish_outputs <- list()
  post_fish_outputs <- lapply(species_list, function(species){ 
    one_spec <- fish_outputs[[species]]
    for(i in 1:length(one_spec)){ # extracts the outputs by species into their own object
      tempobj = one_spec[[i]]
      eval(parse(text=paste(names(one_spec)[[i]],"=tempobj")))
    }
    
    # Flow-Scenario related scripts
    source("interp.table.R")
    inter_tab <- lapply(lifestages, function(a) interp.table(a,s,area_look_tab,NormalizeByL))
    names(inter_tab) <- lifestages
    post_fish_outputs$inter_tab <- inter_tab
    
    # Generate and view plots of total area through the hydrograph
    source("interp.plot.R")
    inter_plots <- interp.plot(inter_tab,NormalizeByL)
    names(inter_plots) <- species
    post_fish_outputs$inter_plots <- inter_plots
    
    ## Generate Data Frames of moving X-Day area and discharge statistics
    if(CalcXDayStats=="Yes"){
      source("x.day.stats.R")
      x_day_stats <- lapply(lifestages, function(a) x.day.stats(a,inter_tab,x_days,NormalizeByL,reach_length))
      names(x_day_stats) <- lifestages
      post_fish_outputs$x_day_stats <- x_day_stats
    }
    
    source("avg.month.area.R")
    avg_monthly_area <- lapply(lifestages, function(a) avg.month.area(a,inter_tab,NormalizeByL))
    names(avg_monthly_area) <- lifestages
    post_fish_outputs$avg_monthly_area <- avg_monthly_area
    # end of flow scenario dependent processes
    
    return(post_fish_outputs)
  }) # end of single species function
  
  names(post_fish_outputs) <- species_list
  
  return(post_fish_outputs)
}) # end of flow scenario list function
names(scene_fish_out) <- names(scene_list)

# save outputs (dss_outputs) for internal use
for(s in 1:length(scene_fish_out)){
  scene <- names(scene_fish_out)[[s]]
  list.save(scene_fish_out[[s]],file=paste(reach_wd,"dss_outputs/",reach_name,"_",scene,"_post_fish.rdata",sep=""))
}

source("calc.hab.retention.R")
hab_retention <- lapply(scene_fish_out, habitat.retention())


# Riparian vegetation post-processing
output_name <- load(file=paste(reach_wd,reach_name,"_pre_outputs.rdata",sep="")) # load rasterized 2D modeling results
eval(parse(text=paste("pre_outputs=",output_name)))

out_val_rast <- pre_outputs$out_val_rast
modeled_q <- pre_outputs$modeled_q

scene_veg_out <- list()
scene_veg_out <- lapply(scene_list, function(s){
  
  source("q.ep.weibull.R")
  hydro_ep <- q.ep.weibull(s,modeled_q)
  scene_veg_out$hydro_ep <- hydro_ep
  
  source("make.ep.maps.R")
  ep_map <- make.ep.maps(hydro_ep,out_val_rast,modeled_q)
  scene_veg_out$ep_map <- ep_map
  
  # make maps of probability of occurrence of vegetation
  all_veg_logit <- fread(paste(reach_wd,"habitat_info","/",reach_name,"_veg_pref",".csv",sep=""),
                        header=TRUE, sep = ",",data.table = FALSE) # load logistic equations
  
  source("find.veg.logit.R"); source("find.prob.occur.R"); source("make.veg.maps.R")
  scene_veg_out$prob_veg_maps <- lapply(veg_list, function(v) {
    one_veg_logit <- find.veg.logit(all_veg_logit,v)
    hydro_ep_prob <- find.prob.occur(v,hydro_ep,one_veg_logit) # outputs table of discharge, EP of discharge, and Prob of Veg for discharge
    prob_veg_maps <- make.veg.maps(v,ep_map,hydro_ep_prob)
    return(prob_veg_maps)
  })

  return(scene_veg_out)
}) # end of flow scenario list function
names(scene_veg_out) <- names(scene_list)

#writeRaster(ep_map,filename = "USBeasley1_30yr_EPmap.tif",format="GTiff")
#writeRaster(wet_map,filename = "USBeasley1_30yr_InunQmap.tif",format="GTiff")

plot(prob_veg_maps)
