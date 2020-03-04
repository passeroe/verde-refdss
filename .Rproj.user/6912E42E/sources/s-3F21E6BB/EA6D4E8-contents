# This function will make tables of high probability of occurrence areas by scenario
# Last edited by Elaina Passero on 2/24/20

make.hp.area.tables <- function(v,high_prob_areas,scene_names,NormalizeByL,reach_length){
  
  calc_hp_area <- function(one_map){ # calculate high probability area
    cell_size <- xres(one_map)^2
    sum_cells_scene <- cellStats(one_map,stat='sum',na.rm=TRUE)
    if(NormalizeByL == "Yes"){
      area <- data.frame(normalized_area = cell_size*sum_cells_scene/reach_length)
    }else{
      area <- data.frame(total_area = cell_size*sum_cells_scene)
    }
    return(area)
  }
  
  hp_area_list <- map(high_prob_areas,calc_hp_area)
  names(hp_area_list) <- scene_names
  all_scene_hp_area_df <- bind_rows(hp_area_list,.id="scene")
  
  write.csv(all_scene_hp_area_df, file = paste(reach_wd, "dss_outputs/",reach_run,"_","veg", "_", v, "_hp_area.csv", sep = ""), append = TRUE)
  
  return(all_scene_hp_area_df)

}

