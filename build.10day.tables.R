# This script will create summary tables associated with 10-day minimum monthly habitat area for each species
# last edited by Elaina Passero on 12/06/19


build.10day.tables <- function(species,scene_list,scene_fish_out){
  
  
  ten_day_min_out <- list()
  
  ## create table of 10-day minimum habitat area that includes all scenarios
  ten_day_min <- data.frame()
  for(i in 1:length(scene_list)){
    avg_mon_area <- scene_fish_out[[i]][[species]][["avg_monthly_area"]][[1]] %>%
      mutate(scene = names(scene_list)[i])
    ten_day_min <- bind_rows(ten_day_min,avg_mon_area)
  }
  
  # # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  # dif <- ten_day_min %>%
  #   pivot_wider(names_from = scene, values_from = mon_avg_low_area) %>%
  #   mutate(per_chg = ((red_25_percent-baseline)/baseline*100))
  # ten_day_min_out$dif <- dif
  # 
  # # df of count of months with greater than 10% reduction in habitat area based on 10-day minimum monthly area
  # dif_count <- dif %>%
  #   dplyr::group_by(month) %>%
  #   summarize(red_count = sum(per_chg <= -10))
  # ten_day_min_out$dif_count <- dif_count
  
  ## Create tables of average 10-day minimum monthly habitat summarized by month for all years
  sum_all_yrs <- ten_day_min %>%
    dplyr::group_by(scene) %>%
    dplyr::group_by(month,add=TRUE) %>%
    summarize(mon_avg = mean(mon_avg_low_area)) #%>%
    #pivot_wider(names_from = scene, values_from = mon_avg)
  ten_day_min_out$sum_all_yrs <- sum_all_yrs
  
  # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  # sum_all_yrs_dif <- sum_all_yrs %>%
  #   mutate(per_chg = ((red_25_percent-baseline)/baseline*100))
  # ten_day_min_out$sum_all_yrs_dif <- sum_all_yrs_dif
  # 
  
  # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  sum_all_yrs_dif <- data.frame()
  for(j in 2:length(scene_list)){
    scene_name <- names(scene_list)[[j]]
    
    wide_tab <- sum_all_yrs %>%
      filter(scene == "baseline" | scene == paste(scene_name)) %>%
      pivot_wider(names_from = scene, values_from = mon_avg)
    
    per_chg_tab <- wide_tab %>%
      mutate(per_chg = ((wide_tab[[paste(scene_name)]]-wide_tab[["baseline"]])/wide_tab[["baseline"]]*100)) %>%
      select(month,per_chg) %>%
      mutate(scene = scene_name)
    
    sum_all_yrs_dif <- bind_rows(sum_all_yrs_dif,per_chg_tab)
  }
  ten_day_min_out$sum_all_yrs_dif <- sum_all_yrs_dif
  
  return(ten_day_min_out)
}