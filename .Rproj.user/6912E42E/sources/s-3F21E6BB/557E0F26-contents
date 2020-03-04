# This function will identify areas with high probability of occurrence of vegetation guilds
# Last edited by Elaina Passero 3/2/20

id.high.prob.areas <- function(scene_veg_out,scene_name){
  prob_veg_map <- scene_veg_out[[scene_name]]
  threshold <- 0.7 # threshold to be considered high probability of occurrence
  
  # select areas of high prob occurrence
  rcl_qual <- data.frame(from = c(-Inf,threshold),
                         to = c(threshold,Inf),
                         becomes = c(0,1)) %>%
    as.matrix(.)
  
  high_prob_map <- reclassify(prob_veg_map,rcl_qual)
  return(high_prob_map)
}
