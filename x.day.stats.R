# This function calculates moving X-day minimum, maximum, and mean discharge and total area 
# Returns a new data frame containing the metrics by date 
# Last edited by Elaina Passero 10/18/19

x.day.stats <- function(a,inter_tab,x_days){
  move_df <- data.frame(date=inter_tab[[a]]$date)
  allDays <- length(move_df$date)
  for(i in 1:(allDays-x_days)){
    last_day <- (x_days-1)+i
    run_days <- dplyr::slice(inter_tab[[a]],i:last_day) # creates subset of observations for X-days
    move_df$x_day_avg_q[last_day] <- mean(run_days$discharge)
    move_df$x_day_avg_area[last_day] <- mean(run_days$total_area)
    move_df$x_day_min_q[last_day]<-min(run_days$discharge)
    move_df$x_day_min_area[last_day]<-min(run_days$total_area)
    move_df$x_day_max_q[last_day]<-max(run_days$discharge)
    move_df$x_day_max_area[last_day]<-max(run_days$total_area)
  }
  return(move_df)
}
  