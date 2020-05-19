# This function generates flow scenarios from historic flow record
# Last edited by Elaina Passero on 11/18/19

library(dataRetrieval)
library(tidyr)
library(nlstools)
library(dplyr)
library(lubridate)
library(rlist)


# Get hydrograph or flow scenario

### Using USGS gage data for hydrograph
my_site<-'09506000' # 08263500 (Rio Grande), 06752260 (Cache la Poudre in FoCo), 09506000 (Verde River near Camp Verde), 03171000 (New River at Radford, VA),
# 09380000 (Colorado River DS of Glen Canyon Dam), 09402500 (Colorado River near Grand Canyon)
parameterCd <- "00060"
start_date <- "1950-10-01"
end_date <- "2019-08-31"
daily_mean <-readNWISdv(my_site,parameterCd,start_date,end_date)
hydrograph <- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)


### Using external flow scenario
# Yes or No. Yes - limit analysis to supplied dates. No - consider entire hydrograph.
DateRange <- "No"; if(DateRange=="Yes"){
  start_date <- "2008-01-01" # "YYYY-MM-DD"
  end_date <- "2018-12-31"} # "YYYY-MM-DD"


hydrograph <- na.omit(fread(paste(reach_wd,"flow_scenarios","/",reach_name,"_baseline_q",".csv",sep=""),
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


# Inputs
reach_name <- "USBeasley1" # Should match name of folder with results
dis_unit <- "cms" #units of discharge

# Yes or No. Choose whether to save flow scenario
SaveScene <- "Yes" 
if(SaveScene == "Yes"){
  scene_name <- "scenario_A"
}

hydroperiods <- c("03-19","06-01","09-01","12-01") # the start dates (mm-dd) of each hydroperiod
hp_names <- c("spring","summer","fall","winter")


## Add inputs in the following order: hydroperiod name, enforce median (y/n), 
# median discharge for season (put NA if not enforcing median), 
# fixed change (withdrawal or return flow), percent change in flow as a decimal (+/-) 

inputs_hp <- list(
  spring <- list("spring","Yes",4.47,0,-.25),
  summer <- list("summer","Yes",4.47,0,-.25),
  fall <- list("fall","Yes",4.47,0,-.25),
  winter <- list("winter","Yes",4.47,0,-.25)
)

# add hydroperiods to hydrograph
source("add_hydroperiods.R")
hydrograph_hp <- add_hydroperiods(hydroperiods,hp_names,hydrograph) 

# applies alterations to historic flow record
source("alter.hydrograph.R")
scene_by_hp <- lapply(inputs_hp, function(h){
  hp <- h[[1]]
  EnforceMed <- h[[2]]
  median_q <- h[[3]]
  fixed_chg <- h[[4]]
  per_chg <- h[[5]]
  alter.hydrograph(hydrograph_hp,EnforceMed,median_q,fixed_chg,per_chg,hp)
})
names(scene_by_hp) <- hp_names

# create df of flow scenario
flow_scene <- bind_rows(scene_by_hp) %>%
  arrange(date)

# Save scenario info
if(SaveScene == "Yes"){
  scene_info <- list(hydroperiods,hp_names,inputs_hp)
  list.save(scene_info,file=paste(reach_wd,"flow_scenarios","/",scene_name,"_inputs",".rdata",sep="")) # inputs
  write.csv(flow_scene,file=paste(reach_wd,"flow_scenarios","/",reach_name,"_",scene_name,".csv",sep=""),row.names = FALSE) # output
}


