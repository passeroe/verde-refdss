# This script will be used to compare scenarios and conduct tradeoff evaluation
# Last edited by Elaina Passero on 2/24/20

# Load required packages
packages <- c("SDMTools","sp","raster","rgeos","rgdal","sf","spatstat","spdep","tidyverse","rasterVis",
              "ggplot2","data.table","dplyr","spex","stars","igraph","deldir","hydroTSM",
              "lubridate","rlist")
#  Check to see if each is installed, and install if not.
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {    
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
# load the installed libraries in the packages list 
lapply(packages,library,character.only=TRUE)
###########################################

# User inputs
post_tag <- "pt" # unique code to identify current run of DSS

wd <- "C:/Users/epassero/Desktop/VRDSS/verde-refdss/" # Project working directory
#wd <- "/Users/Morrison/Documents/Active Research Projects/Verde REFDSS/verde-refdss/" # Set path to local repository
setwd(wd)

hab_mets <- list("Depth","Velocity") #Variables from iRIC calculation result used for habitat analysis - case sensitive
#species_list <- c("longfindace","desertsucker") #"sonoransucker") #"yellowbullhead", "sonoransucker","redshiner","roundtailchub","greensunfish","fatheadminnow","speckleddace")
species_list <- c("desertsucker","smallmouthbass") # fish species list
native_list <- c("desertsucker") # list of native fish species in species_list
lifestages <- list("adult") #lifestages from oldest to youngest; must match order in HSC table
veg_list <- c("drgt_tol_shrubs","tall_trees") # vegetation group list
reach_name <- "USBeasley1" # Should match name of folder with results
model_run <- "2.12.20" # Should match end of name of folder with results
dis_unit <- "cms" #units of discharge

# Flow scenarios to compare to baseline conditions
scene_names <- c("baseline_q","red_25_percent")

# Yes or No. Choose whether or not to normalize habitat area by reach length
NormalizeByL <- "Yes"; if(NormalizeByL=="Yes"){
  reach_length <- 0.5
  length_unit <- "km"}

### End of User Inputs ###

### Begin scenario comparison ###
reach_run <- paste(reach_name,"_",model_run,sep="")
reach_wd <- paste(wd,"reaches","/",reach_run,"/",sep = "")

# create list of flow scenario data frames
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



# Figures and tables for fish
post_fish_figs <- list()
post_fish_figs <- lapply(species_list, function(species){
  
  # Load all scenario results for species
  scene_fish_out <- list()
  scene_fish_out <- lapply(scene_names, function(scene_name){
    output_name <- load(file=paste(reach_wd,"dss_outputs/","internal/",reach_run,"_",scene_name,"_post_",species,".rdata",sep="")) # load post-fish outputs
    eval(parse(text=paste("hold_fish_output=",output_name)))
    return(hold_fish_output)
  })
  names(scene_fish_out) <- scene_names

  
  source("plot.10day.ts.R")
  ten_day_ts_plt <- lapply(lifestages, function(a) plot.10day.ts(a,species,scene_fish_out,scene_list,NormalizeByL,post_tag))
  names(ten_day_ts_plt) <- lifestages
  post_fish_figs$ten_day_ts_plt <- ten_day_ts_plt 
  
  source("build.10day.tables.R")
  ten_day_min_outputs <- lapply(lifestages, function(a) build.10day.tables(a,species,scene_list,scene_fish_out,post_tag))
  names(ten_day_min_outputs) <- lifestages
  post_fish_figs$ten_day_min_outputs <- ten_day_min_outputs
  
  source("make.barplots.chg.R")
  chg_barplots <- lapply(lifestages, function(a) make.barplots.chg(a,species,ten_day_min_outputs))
  names(chg_barplots) <- lifestages
  post_fish_figs$chg_barplots <- chg_barplots
  
  return(post_fish_figs)
})
names(post_fish_figs) <- species_list


# Figures and tables for vegetation
# load inundating discharge map
wet_map <- raster(paste(reach_wd,"dss_outputs/",reach_run,"_baseline_q_wet_map.tif",sep=""))
sum_veg_metrics <- list()
sum_veg_metrics <- lapply(veg_list, function(v) {
  
  scene_veg_out <- lapply(scene_names, function(scene_name){
    output_name <- load(file=paste(reach_wd,"dss_outputs/","internal/",reach_run,"_",scene_name,"_post_",v,".RData",sep=""))
    eval(parse(text=paste("hold_veg_output=",output_name)))
    return(hold_veg_output)
  })
  names(scene_veg_out) <- scene_names
  
  # identify areas of high probability of occurrence
  source("id.high.prob.areas.R")
  high_prob_areas <- lapply(scene_names, function(scene_name) id.high.prob.areas(scene_veg_out,scene_name))
  names(high_prob_areas) <- scene_names
  sum_veg_metrics$high_prob_areas <- high_prob_areas
  
  # maps of change in high probability of occurrence areas
  source("map.chg.veg.areas.R")
  chg_high_prob_areas <- lapply(scene_names, function(scene_name) map.chg.veg.areas(high_prob_areas,scene_name))
  names(chg_high_prob_areas) <- scene_names
  sum_veg_metrics$chg_high_prob_areas <- chg_high_prob_areas
  
  # Tabulate area of high probability of occurrence
  source("make.hp.area.tables.R")
  hp_area_tab <- make.hp.area.tables(v,high_prob_areas,scene_names)
  sum_veg_metrics$hp_area_tab <- hp_area_tab
  
  # Calculate % change in high probability of occurrence areas
  source("calc.chg.veg.area.R")
  per_chg_hp_tab <- calc.chg.veg.area(hq_area_tab,scene_names,NormalizeByL)
  sum_veg_metrics$per_chg_hp_tab <- per_chg_hp_tab
  
  # describe movement of high probability of occurrence areas
  source("check.veg.movement.R")
  veg_movement <- lapply(scene_names, function(scene_name) check.veg.movement(wet_map,high_prob_areas,scene_name))
  names(veg_movement) <- scene_names
  sum_veg_metrics$veg_movement <- veg_movement
  
  return(sum_veg_metrics)
})
names(sum_veg_metrics) <- veg_list

# Compare scenarios using fish and vegetation metrics
