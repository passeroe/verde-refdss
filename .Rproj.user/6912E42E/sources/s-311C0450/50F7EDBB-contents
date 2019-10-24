# This script will export rasters from out_val_rast into their own folder for subsequent processing
# Last edited by Elaina Passero on 10/18/19

export.rast <- function(out_val_rast,modeled_q){
  brickByQ <- brick(order.by.q(1,out_val_rast,modeled_q))
  
  rclmat <- matrix(c(0,Inf,1, -Inf,0,NA),ncol=3,byrow=TRUE)
  wet_brick <- reclassify(brickByQ,rclmat)
  for(j in 1:nlayers(wet_brick)){
    wet_brick[[j]] <- wet_brick[[j]]*sort_q[j] # apply discharge value to inundated areas
  }
  
  # use cover() function to make layer of inundating discharge
  wet_map <- wet_brick[[1]]
  
  for(j in 1:nlayers(wet_brick)){
    wet_map <- cover(wet_map,wet_brick[[j]])
  }
  writeRaster(wet_map,filename = "inunQmap.tif",format="GTiff")
}
