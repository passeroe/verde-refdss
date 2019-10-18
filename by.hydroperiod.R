# This script is the starting point for separating analysis by hydroperiods

library(dataRetrieval)
library(hydroTSM)
library(xts)
library(lubridate)
library(lplyr)


# Pull data directly from USGS gage
##### Flow duration stuff
mysite<-'08263500'
parameterCd <- "00060"
startDate <- "1990-10-01"
endDate <- "2019-08-28"
dailymean<-readNWISdv(mysite,parameterCd,startDate,endDate)
hydrograph <- data.frame(date=dailymean$Date,discharge=dailymean$X_00060_00003) # generate hydrograph from USGS gage data

### Using internal data ###
# read in the hydrograph
hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

enforceMed <- "Yes"
perRed <- 0.20 # percent flow reduction
medianQ <- 160 # median flow value - could use monthly or annual
withdrawal <- 5


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


## Subset by Julian dates MM-DD
hydroPeriodList <- list(c(
  startP1= "04/30", # snowmelt
  startP2 = "07/15", # monsoon
  startP3 = "08/31" # dry
)) # end of date list


startP1 <- "04/30"
endP1 <- "07/15"
dp1 <- as.Date(startP1,format="%m/%d")
Date <- as.Date("2019-08-28")

month(Date) >= month(dp1) && day(Date) > day(dp1) && month(Date) <= month(dp1) && day(Date) <= day(dp1)


