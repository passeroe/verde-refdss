# This function will identify areas with high probability of occurrence of vegetation guilds
# Last edited by Elaina Passero 2/24/20

id.high.prob.areas <- function(scene_veg_out,scene_name){
  prob_veg_map <- scene_veg_out[[scene_name]]
  
  # select areas of high prob occurrence
  rcl_qual <- data.frame(from = c(-Inf,0.7),
                         to = c(0.7,Inf),
                         becomes = c(0,1)) %>%
    as.matrix(.)
  
  high_prob_map <- reclassify(prob_veg_map,rcl_qual)
  return(high_prob_map)
}
