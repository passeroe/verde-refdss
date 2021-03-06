# This script will export rasters from out_val_rast into their own folder for subsequent processing
# Last edited by Elaina Passero on 10/25/19

export.rast <- function(out_val_rast,modeled_q, reach_wd){
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
  writeRaster(wet_map,filename = paste(reach_wd, "dss_outputs/", "inun_q_map.tif", sep = ""),format="GTiff") # export inundating Q map 
  
  
  
}


species_list <- c("sonorasucker","desertsucker","smallmouthbass","redshiner") # species list for chris
extract_list <- list("cms_1","cms_5","cms_8","cms_16","cms_80","cms_250","cms_1050") # discharges to pull results for

# extract Depth
for(i in 1:length(extract_list)){
  name <- extract_list[[i]]
  layer <- out_val_rast$Depth[[name]]
  writeRaster(layer,filename = paste(reach_wd,reach_name,"_",name,"_depth.tif",sep=""),format="GTiff")
}

# extract Velocity
for(i in 1:length(extract_list)){
  name <- extract_list[[i]]
  layer <- out_val_rast$Velocity[[name]]
  writeRaster(layer,filename = paste(reach_wd,reach_name,"_",name,"_vel.tif",sep=""),format="GTiff")
}

# extract WSE
for(i in 1:length(extract_list)){
  name <- extract_list[[i]]
  layer <- out_val_rast$WaterSurfaceElevation[[name]]
  writeRaster(layer,filename = paste(reach_wd,reach_name,"_",name,"_wse.tif",sep=""),format="GTiff")
}

# extract Shear Stress
for(i in 1:length(extract_list)){
  name <- extract_list[[i]]
  layer <- out_val_rast$ShearStress[[name]]
  writeRaster(layer,filename = paste(reach_wd,reach_name,"_",name,"_shear.tif",sep=""),format="GTiff")
}


