# This function will calculate the percent change from baseline in high probability of occurrence areas
# Last edited by Elaina Passero 2/24/20

calc.chg.veg.area <- function(hp_area_tab,scene_names,NormalizeByL){
  
  scenes <- scene_names[scene_names != "baseline_q"]
  per_chg_hp_tab <- data.frame()
  for(j in 1:length(scenes)){
    scene_name <- scenes[j]
    
    if(NormalizeByL == "Yes"){
      wide_tab <- hp_area_tab %>%
        filter(scene == "baseline_q" | scene == paste(scene_name)) %>%
        pivot_wider(names_from = scene, values_from = normalized_area)
      
      add_tab <- wide_tab %>%
        mutate(per_chg = ((wide_tab[[paste(scene_name)]]-wide_tab[["baseline_q"]])/wide_tab[["baseline_q"]]*100)) %>%
        select(per_chg) %>%
        mutate(scene = scene_name)
      
      per_chg_hp_tab <- bind_rows(per_chg_hp_tab,add_tab) 
    } else{
      wide_tab <- hq_area_tab %>%
        filter(scene == "baseline_q" | scene == paste(scene_name)) %>%
        pivot_wider(names_from = scene, values_from = total_area)
      
      add_tab <- wide_tab %>%
        mutate(per_chg = ((wide_tab[[paste(scene_name)]]-wide_tab[["baseline_q"]])/wide_tab[["baseline_q"]]*100)) %>%
        select(per_chg) %>%
        mutate(scene = scene_name)
      
      per_chg_hp_tab <- bind_rows(per_chg_hp_tab,add_tab)  
    }
  } # end of for loop

  return(per_chg_hp_tab)
}