# Calculates median monthly flow and applies critieria
# Last edited by Elaina Passero on 12/09/19

### Using external flow scenario
# Yes or No. Yes - limit analysis to supplied dates. No - consider entire hydrograph.
DateRange <- "No"; if(DateRange=="Yes"){
  start_date <- "2008-01-01" # "YYYY-MM-DD"
  end_date <- "2018-12-31"} # "YYYY-MM-DD"


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

# reduce flows above monthly median flow by 25%
med_months <- hydrograph %>%
  dplyr::group_by(month(date)) %>%
  dplyr::summarise(med = median(discharge))

red_above_med_25 <- data.frame()
for(m in 1:12){
  med_q <- as.numeric(med_months[m,2])
  hydro <- filter(hydrograph,month(date)==m) %>%
    dplyr::mutate(red_q = ifelse(discharge > med_q,discharge*0.75,discharge))
  red_above_med_25 <- dplyr::bind_rows(red_above_med_25,hydro)
}
red_above_med_25 <- select(red_above_med_25,-discharge) %>%
  dplyr::rename(discharge = red_q)
write.csv(red_above_med_25,file="red_above_med_25_ts.csv")


# trying out the map function to replace an lapply statement
veg.mapping <- function(v){
  one_veg_logit <- find.veg.logit(all_veg_logit,v)
  hydro_ep_prob <- find.prob.occur(v,hydro_ep,one_veg_logit) # outputs table of discharge, EP of discharge, and Prob of Veg for discharge
  prob_veg_maps <- make.veg.maps(v,ep_map,hydro_ep_prob,scene_name)
  return(prob_veg_maps)
}



