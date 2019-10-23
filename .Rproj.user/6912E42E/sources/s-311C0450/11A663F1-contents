# This function calculates moving X-day minimum, maximum, and mean discharge and total area 
# Returns a new data frame containing the metrics by date 
# Last edited by Elaina Passero 10/23/19

### Should add option to calculate stats on normalized area - can just divide all area stats by length

x.day.stats <- function(a,inter_tab,x_days,NormalizeByL,reach_length){
  if(NormalizeByL == "Yes"){
    move_df <- data.frame(date=inter_tab[[a]]$date,
                          actual_q = inter_tab[[a]]$discharge,
                          actual_tot_area = inter_tab[[a]]$total_area,
                          actual_norm_area = inter_tab[[a]]$normalized_area,
                          x_day_avg_area = NA, x_day_avg_norm_area = NA,
                          x_day_min_area = NA, x_day_min_norm_area = NA,
                          x_day_max_area = NA, x_day_max_norm_area = NA)
    all_days <- length(move_df$date)
    for(i in 0:(all_days-x_days)){
      last_day <- x_days+i
      run_days <- dplyr::slice(inter_tab[[a]],i:last_day) # creates subset of observations for X-days
      move_df$x_day_avg_area[last_day] <- mean(run_days$total_area)
      move_df$x_day_avg_norm_area[last_day] <- mean(run_days$normalized_area)
      move_df$x_day_min_area[last_day]<-min(run_days$total_area)
      move_df$x_day_min_norm_area[last_day]<-min(run_days$normalized_area)
      move_df$x_day_max_area[last_day]<-max(run_days$total_area)
      move_df$x_day_max_norm_area[last_day]<-max(run_days$normalized_area)
    }
  } else {
    move_df <- data.frame(date=inter_tab[[a]]$date,
                          actual_q = inter_tab[[a]]$discharge,
                          actual_area = inter_tab[[a]]$total_area,
                          x_day_avg_area = NA,
                          x_day_min_area = NA,
                          x_day_max_area = NA)
    all_days <- length(move_df$date)
    for(i in 0:(all_days-x_days)){
      last_day <- x_days+i
      run_days <- dplyr::slice(inter_tab[[a]],i:last_day) # creates subset of observations for X-days
      move_df$x_day_avg_area[last_day] <- mean(run_days$total_area)
      move_df$x_day_min_area[last_day]<-min(run_days$total_area)
      move_df$x_day_max_area[last_day]<-max(run_days$total_area)
    }
  }
  
  return(move_df)
}
