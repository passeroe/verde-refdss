# This script will make maps of probability of occurrence of vegetation guilds/species
# Last edited by Elaina Passero on 01/24/20

make.veg.maps <- function(v,ep_map,hydro_ep_prob,scene_name){
  
  # build matrix for reclassification
  rcl_ep <- data.frame(from = c(hydro_ep_prob$EP[-1],0),
                       to = hydro_ep_prob$EP,
                       becomes = hydro_ep_prob$prob_v) %>%
    as.matrix(.)
  
  # reclassify raster
  prob_veg_map <- reclassify(ep_map, rcl_ep, right = TRUE)
  
  
  writeRaster(prob_veg_map,filename = paste(reach_wd,"dss_outputs/",reach_name,"_",scene_name,"_",v,"_prob_map.tif",sep=""),
              format="GTiff",overwrite=TRUE)
  return(prob_veg_map) 
}
