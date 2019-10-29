# This function generates flow scenarios from historic flow record
# Last edited by Elaina Passero on 10/29/19

library(dataRetrieval)
library(nlstools)

# Get hydrograph or flow scenario

### Using USGS gage data for hydrograph
my_site<-'06752260' # 08263500 (Rio Grande), 06752260 (Cache la Poudre in FoCo), 09506000 (Verde River near Camp Verde), 03171000 (New River at Radford, VA),
# 09380000 (Colorado River DS of Glen Canyon Dam), 09402500 (Colorado River near Grand Canyon)
parameterCd <- "00060"
start_date <- "1950-10-01"
end_date <- "2019-08-31"
daily_mean<-readNWISdv(my_site,parameterCd,start_date,end_date)
hydrograph<- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)


### Using external flow scenario
hydrograph <- na.omit(fread(paste(reach_wd,"flow_scenarios","/",reach_name,"_hydrograph",".csv",sep=""),
                            header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

make.flow.scenario <- function(hydrograph,enforce_med,median_q,withdrawal,per_red){
  if(withdrawal > 0){ # fixed withdrawal
    if(enforce_med == "Yes"){
      for(r in 1:length(hydrograph$date)){
        if(hydrograph$discharge[[r]] > median_q){
          hydrograph$revised_q[[r]] <- hydrograph$discharge[[r]]-withdrawal
        } else{
          hydrograph$revised_q[[r]] <- hydrograph$discharge[[r]]
        }
      }
    } else{
      hydrograph$revised_q <- hydrograph$discharge-withdrawal
    }
  }
  
  if(per_red > 0){ # percent withdrawal
    if(enforce_med == "Yes"){
      for(s in 1:length(hydrograph$date)){
        if(hydrograph$discharge[[s]] > median_q){
          hydrograph$revised_q[[s]] <- hydrograph$discharge[[s]]*(1-per_red)
        } else{
          hydrograph$revised_q[[s]] <- hydrograph$discharge[[s]]
        }
      }
    } else{
      hydrograph$revised_q <- hydrograph$discharge*(1-per_red)
    }
  }
  
  hydrograph <- hydrograph %>%
    select(-discharge) %>%
    rename(discharge = revised_q)
  
  return(hydrograph)
}