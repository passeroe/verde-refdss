# this function will reclassify inundating q map with EP values from a flow scenario.
# last edited by Elaina Passero on 12/09/19

make.ep.maps <- function(hydro_ep,out_val_rast,modeled_q,scene_name){
  
  source("order.by.q.R")
  hold <- order.by.q(1,out_val_rast,modeled_q,"No")
  brick_by_q <- brick(hold[[1]])
  sort_q <- hold[[2]]
  
  rclmat <- matrix(c(0,Inf,1, -Inf,0,NA),ncol=3,byrow=TRUE)
  wet_brick <- reclassify(brick_by_q,rclmat)
  for(j in 1:nlayers(wet_brick)){
    wet_brick[[j]] <- wet_brick[[j]]*sort_q[j] # apply discharge value to inundated areas
  }
  
  # use cover() function to make layer of inundating discharge
  wet_map <- wet_brick[[1]]
  
  for(j in 1:nlayers(wet_brick)){
    wet_map <- cover(wet_map,wet_brick[[j]]) # inundating Q map
  }

  # get EP values for modeled discharges
  modeled_q_ep <- hydro_ep %>%
    filter(discharge %in% modeled_q) %>%
    distinct() %>%
    arrange(discharge)
  
  # build matrix for reclassification
  rcl_ep <- data.frame(from = modeled_q_ep$discharge,
               to = c(modeled_q_ep$discharge[-1],Inf), 
               becomes = modeled_q_ep$EP) %>%
    as.matrix(.)
  
  # reclassify raster
  ep_map <- reclassify(wet_map, rcl_ep, right = FALSE)
  
  writeRaster(ep_map,filename = paste(reach_wd,"dss_outputs/",reach_name,"_",scene_name,"_ep_map.tif",sep=""),
              format="GTiff",overwrite = TRUE)
  return(ep_map) 
}

