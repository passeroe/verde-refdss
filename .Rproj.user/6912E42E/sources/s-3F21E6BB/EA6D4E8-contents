# This function will make tables of high probability of occurrence areas by scenario
# Last edited by Elaina Passero on 2/24/20

make.hp.area.tables <- function(v,high_prob_areas,scene_names){
  
  if(NormalizeByL == "Yes"){
    hp_area_tab <- data.frame()
  } else {
    hp_area_tab <- data.frame()
  }
  
  for(i in 1:length(scene_names)){
    scene_name <- scene_names[i]
    scene_hp_map <- high_prob_areas[[i]]
    
    # calculate high probability area
    cell_size <- xres(scene_hp_map)^2
    sum_cells_scene <- cellStats(scene_hp_map,stat='sum',na.rm=TRUE)
    scene_area <- cell_size*sum_cells_scene
    
    df_entry <- data.frame(scene_names[i],scene_area)
    hp_area_tab <- rbind(hp_area_tab,df_entry)
  }
  
  write.csv(hp_area_tab, file = paste(reach_wd, "dss_outputs/",reach_run,"_",veg, "_", v, "_hp_area.csv", sep = ""), append = TRUE)
  
  return(hp_area_tab)
}
rm(df_entry)
