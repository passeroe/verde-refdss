# This function calculates moving X-day minimum, maximum, and mean discharge and total area 
# Returns a new data frame containing the metrics by date 
# Last edited by Elaina Passero 5/20/19

x.day.stats <- function(a,interTab,xDays){
  moveDF <- data.frame(date=interTab[[a]]$date)
  allDays <- length(moveDF$date)
  for(i in 1:(allDays-xDays)){
    lastDay <- (xDays-1)+i
    runDays <- dplyr::slice(interTab[[a]],i:lastDay) # creates subset of observations for X-days
    moveDF$xDayAvgQ[lastDay] <- mean(runDays$discharge)
    moveDF$xDayAvgArea[lastDay] <- mean(runDays$totalArea)
    moveDF$xDayMinQ[lastDay]<-min(runDays$discharge)
    moveDF$xDayMinArea[lastDay]<-min(runDays$totalArea)
    moveDF$xDayMaxQ[lastDay]<-max(runDays$discharge)
    moveDF$xDayMaxArea[lastDay]<-max(runDays$totalArea)
  }
  return(moveDF)
}
  