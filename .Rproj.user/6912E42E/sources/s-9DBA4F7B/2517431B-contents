# This function calculates monthly area using central 10-day lowest consecutive area values
# Returns a data frame with average monthly area
# should update to run without normalizing area
# Last edited by Elaina Passero on 10/21/19

avg.month.area <- function(a,inter_tab,NormalizeByL){
  # Monthly stats using lowest consecutive 10 days
  move_df <- data.frame(date=inter_tab[[a]]$date,low10d_avg_area=NA)
  all_days <- length(move_df$date)
  for(i in seq(5,(all_days-5),1)){
    day_1 <- i-4
    day_last <- i+5
    run_days <- dplyr::slice(inter_tab[[a]],day_1:day_last) # creates subset of observations for X-days
    if(NormalizeByL == "Yes"){
      move_df[i,2] <- mean(run_days$normalized_area)
    } else {
      move_df[i,2] <- mean(run_days$total_area)
    }
  }
  move_df$day <- as.numeric(format(as.Date(move_df$date,format="%m/%d/%Y"),"%d"))
  low10df <- filter(move_df, is.na(move_df$low10d_avg_area)==FALSE)
  runMonth <- as_tibble(low10df) %>%
    group_by(year(date)) %>%
    group_by(month(date),add=TRUE) %>%
    summarise(mon_avg_low_area=min(low10d_avg_area))
  return(runMonth)
}
