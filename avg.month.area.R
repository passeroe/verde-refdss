# This function calculates monthly area using central 10-day lowest consecutive area values
# Returns a data frame with average monthly area
# Last edited by Elaina Passero on 5/21/19

avg.month.area <- function(a,interTab){
  # Monthly stats using lowest consecutive 10 days
  moveDF <- data.frame(date=interTab[[a]]$date,low10DAvgArea=NA)
  allDays <- length(moveDF$date)
  for(i in seq(5,(allDays-5),1)){
    firstDay <- i-4
    lastDay <- i+5
    runDays <- dplyr::slice(interTab[[a]],firstDay:lastDay) # creates subset of observations for X-days
    moveDF[i,2] <- mean(runDays$normalizedArea)
  }
  moveDF$day <- as.numeric(format(as.Date(moveDF$date,format="%m/%d/%Y"),"%d"))
  low10DF <- filter(moveDF, is.na(moveDF$low10DAvgArea)==FALSE)
  tblTab <- tbl_df(low10DF)
  runMonth <- group_by(tblTab,year(date)) %>%
    group_by(month(date),add=TRUE) %>%
    summarise(MonAvgLowArea=mean(low10DAvgArea))
  return(runMonth)
}
