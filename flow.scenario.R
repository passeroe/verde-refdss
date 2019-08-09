# This script will manipulate the hydrograph to produce flow scenarios.

enforceMed <- "Yes"

perRed <- 0.05 # percent flow reduction
medianQ <- 160 # median flow value - could use monthly or annual
withdrawal <- 5

# read in the hydrograph
hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

# fixed withdrawal
if(enforceMed == "Yes"){
  for(r in 1:length(hydrograph$date)){
    if(hydrograph$discharge[[r]] > medianQ){
      hydrograph$medERevQ[[r]] <- hydrograph$discharge[[r]]-withdrawal
    } else{
      hydrograph$medERevQ[[r]] <- hydrograph$discharge[[r]]
    }
  }
} else{
  hydrograph$subQ <- hydrograph$discharge-withdrawal
}

# percent withdrawal
if(enforceMed == "Yes"){
  for(s in 1:length(hydrograph$date)){
    if(hydrograph$discharge[[s]] > medianQ){
      hydrograph$revisedQ[[s]] <- hydrograph$discharge[[s]]*(1-perRed)
    } else{
      hydrograph$revisedQ[[s]] <- hydrograph$discharge[[s]]
    }
  }
} else{
  hydrograph$revisedQ <- hydrograph$discharge*(1-perRed)
}

