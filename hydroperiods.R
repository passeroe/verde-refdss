# This is where I am messing around with the Julian date thing bc I can't focus with all that shit in the way
# last edited by Elaina Passero on 11/01/19



### Using external flow scenario
hydrograph <- na.omit(fread(paste(reach_wd,"flow_scenarios","/",reach_name,"_hydrograph",".csv",sep=""),
                            header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")







hydroperiods <- c("03-30","09-30","12-01")
hp_names <- c("spring","summer","winter")
intervals <- distinct(data.frame(year=year(hydrograph$date)))
hp_year <- matrix(ncol=length(hydroperiods),nrow=length(intervals$year))
for(i in 1:length(intervals$year)){
  for(j in 1:length(hydroperiods)){
    hp_year[i,j] <- paste(intervals$year[i],"-",hydroperiods[j],sep="")
  }
  hp_df <- data.frame(hp_year,stringsAsFactors = FALSE)
  colnames(hp_df) <- hp_names
  mutate()
}
