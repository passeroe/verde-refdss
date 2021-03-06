# this function will make inundating Q maps for presentation
# Last edited by Elaina Passero on 1/24/20


make.inun.q.map <- function(hydro_ep,out_val_rast,modeled_q,scene_name,reach_run){
  
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

  writeRaster(wet_map,filename = paste(reach_wd,"dss_outputs/",reach_run,"_",scene_name,"_wet_map.tif",sep=""),
              format="GTiff",overwrite = TRUE)
return(wet_map)
}
