# This script will create summary tables associated with 10-day minimum monthly habitat area for each species
# last edited by Elaina Passero on 5/31/20


build.10day.tables <- function(a,species,scene_list,scene_fish_out,post_tag){
  
  
  ten_day_min_out <- list()
  
  ## create table of 10-day minimum habitat area that includes all scenarios
  ten_day_min <- data.frame()
  for(i in 1:length(scene_list)){
    avg_mon_area <- scene_fish_out[[i]][["avg_monthly_area"]][[a]] %>%
      mutate(scene = names(scene_list)[i])
    ten_day_min <- bind_rows(ten_day_min,avg_mon_area)
  }

  ## Create tables of average 10-day minimum monthly habitat summarized by month for all years
  sum_all_yrs <- ten_day_min %>%
    dplyr::group_by(scene) %>%
    dplyr::group_by(month,add=TRUE) %>%
    summarize(mon_avg = mean(mon_avg_low_area))
  ten_day_min_out$sum_all_yrs <- sum_all_yrs
  write.csv(ten_day_min_out$sum_all_yrs,file=paste(reach_wd,"dss_outputs/",post_tag,"_",species,"_",a,"_10day_min_sum.csv",sep="")) # export table
  
  # Calculate % change between baseline and scenario habitat: scene-historic/historic*100
  scenes <- scene_list[scene_list != "baseline_q"]
  sum_all_yrs_dif <- data.frame()
  for(j in 1:length(scenes)){
    scene_name <- names(scenes)[[j]]
    
    wide_tab <- sum_all_yrs %>%
      filter(scene == "baseline_q" | scene == paste(scene_name)) %>%
      pivot_wider(names_from = scene, values_from = mon_avg)
    
    per_chg_tab <- wide_tab %>%
      mutate(per_chg = ((wide_tab[[paste(scene_name)]]-wide_tab[["baseline_q"]])/wide_tab[["baseline_q"]]*100)) %>%
      select(month,per_chg) %>%
      mutate(scene = scene_name)
    
    sum_all_yrs_dif <- bind_rows(sum_all_yrs_dif,per_chg_tab)
  }
  ten_day_min_out$sum_all_yrs_dif <- sum_all_yrs_dif
  
  write.csv(ten_day_min_out$sum_all_yrs_dif,file=paste(reach_wd,"dss_outputs/",post_tag,"_",species,"_",a,"_10day_min_chg.csv",sep=""))
  
  return(ten_day_min_out)
}


