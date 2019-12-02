# This script will create summary tables associated with 10-day minimum monthly habitat area for each species
# last edited by Elaina Passero on 12/2/19


build.10day.tables <- function(species,scene_list,scene_fish_out){
  ten_day_min_out <- list()
  
  ## create table of 10-day minimum habitat area that includes both scenarios
  ten_day_min <- data.frame()
  for(i in 1:length(scene_list)){
    avg_mon_area <- scene_fish_out[[i]][[species]][["avg_monthly_area"]][[1]] %>%
      mutate(scene = names(scene_list)[i])
    ten_day_min <- bind_rows(ten_day_min,avg_mon_area)
  }
  
  # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  dif <- ten_day_min %>%
    pivot_wider(names_from = scene, values_from = mon_avg_low_area) %>%
    mutate(per_chg = ((red_25_percent-hydrograph)/hydrograph*100))
  ten_day_min_out$dif <- dif
  
  # df of count of months with greater than 10% reduction in habitat area based on 10-day minimum monthly area
  dif_count <- dif %>%
    dplyr::group_by(month) %>%
    summarize(red_count = sum(per_chg <= -10))
  ten_day_min_out$dif_count <- dif_count
  
  ## Create tables of average 10-day minimum monthly habitat summarized by month for all years
  sum_all_yrs <- ten_day_min %>%
    dplyr::group_by(scene) %>%
    dplyr::group_by(month,add=TRUE) %>%
    summarize(mon_avg = mean(mon_avg_low_area)) %>%
    pivot_wider(names_from = scene, values_from = mon_avg)
  ten_day_min_out$sum_all_yrs <- sum_all_yrs
  
  # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  sum_all_yrs_dif <- sum_all_yrs %>%
    mutate(per_chg = ((red_25_percent-hydrograph)/hydrograph*100))
  ten_day_min_out$sum_all_yrs_dif <- sum_all_yrs_dif
  
  return(ten_day_min_out)
}




