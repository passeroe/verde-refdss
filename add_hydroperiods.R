# This function adds the hydroperiod a date falls into to the hydrograph
# last edited by Elaina Passero on 11/04/19

add_hydroperiods <- function(hydroperiods,hp_names,hydrograph){
  # create a df of years in hydrograph
  intervals <- distinct(data.frame(year=year(hydrograph$date))) %>%
    bind_rows(data.frame(year=c(min(year(hydrograph$date))-1,
                                max(year(hydrograph$date))+1))) %>% # add in the year before the earliest year in hydrograph
    arrange(year)
  
  # create a df of hydroperiods by year
  hp_year <- matrix(ncol=length(hydroperiods),nrow=length(intervals$year))
  for(i in 1:length(intervals$year)){
    for(j in 1:length(hydroperiods)){
      hp_year[i,j] <- paste(intervals$year[i],"-",hydroperiods[j],sep="")
    }
    hp_df <- data.frame(hp_year,stringsAsFactors = FALSE)
    colnames(hp_df) <- hp_names
  }
  
  # create long df and format dates as date-objects
  hp_df_long <- pivot_longer(hp_df,1:length(hydroperiods),values_to = "date",names_to = "hydroperiod") %>%
    arrange(date) %>%
    mutate(date_as_date = as.Date(date)) %>%
    select(-date) %>%
    rename(date = date_as_date)
  
  full_hp_cal <- hp_df_long # data frame that will receive all of the days
  
  # assign all dates in range of flow record a hydroperiod
  for(k in 1:length(hp_df_long$date)){
    if(k+1 < length(hp_df_long$date)){
      date_df <- data.frame(date = seq.Date(hp_df_long$date[k],hp_df_long$date[k+1]-1,1)) %>%
        mutate(hydroperiod = hp_df_long$hydroperiod[k])
    }
    full_hp_cal <- bind_rows(full_hp_cal,date_df)
  }
  full_hp_cal <- arrange(full_hp_cal,date) %>% # put dates in ascending order and remove any duplicates
    dplyr::distinct()
  
  # join hydroperiods to flow record
  hydrograph <- left_join(hydrograph,full_hp_cal,by="date")
  return(hydrograph)
}

