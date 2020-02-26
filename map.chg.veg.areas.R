# This function will map the change in high probability of occurrence areas from baseline
# Last edited by Elaina Passero on 2/24/20


map.chg.veg.areas <- function(high_prob_areas,scene_name){
  
  # extract maps
  base_map <- high_prob_areas$baseline_q
  scene_map <- high_prob_areas[[scene_name]]
  
  diff_map <- scene_map - base_map
  
  return(diff_map)
}