# This script will describe potential vegetation movement
# Last edited by Elaina Passero on 2/24/20

check.veg.movement <- function(wet_map,high_prob_areas,scene_name){
  # find 1st and 3rd quartiles of inundating discharge that high probability area occurs in
  hp_iq_map_base <- mask(wet_map,high_prob_areas$baseline_q,maskvalue=0,updatevalue=NA)
  hp_iq_map_scene <- mask(wet_map,high_prob_areas[[scene_name]],maskvalue=0,updatevalue=NA)
  
  base_range <- summary(hp_iq_map_base)
  scene_range <- summary(hp_iq_map_scene)
  
  # describe change in high probability of occurrence areas
  if(scene_range[2] < base_range[2]){
    if(scene_range[4] > base_range[4]{
      movement <- "expand"
    }) else{movement <- "encroach"}
  }
    
  if(scene_range[2] > base_range[2]){
    if(scene_range[4] > base_range[4]{
      movement <- "retreat"
    }) else{movement <- "reduce"}
  }
  
  if(scene_range[2] == base_range[2] && scene_range[4] == base_range[4]){
    movement <- "not change"
  }
  
  return(movement)
}

