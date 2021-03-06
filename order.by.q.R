# Function: Puts rasters of total available habitat in order of ascending modeled Q's
# Returns a list of rasters
# Last edited by Elaina Passero on 2/18/20

order.by.q <- function(a,good_hab_list,modeled_q,ExportRast,reach_wd,fish,reach_run){
  if(nlayers(good_hab_list[[a]])==0){
    g <- brick(good_hab_list[[a]]) # ensures a single raster layer will "unstack"
  } else{
    g <- good_hab_list[[a]]
  }
  open_brick <- unstack(g)
  names(open_brick) <- modeled_q
  sort_q <- sort(modeled_q) # sorts from smallest to largest
  rast_by_q <- list()
  for(i in 1:length(sort_q)){ # builds new list with rasters in ascending order by modeled Q
    n <- which(names(open_brick)==sort_q[i])
    rast_by_q[i] <- open_brick[n]
    if(ExportRast == "Yes"){
      writeRaster(open_brick[[n]],
                  filename = paste(reach_wd, "dss_outputs/",reach_run,"_",fish, "_", sort_q[i], "_", a, "_", "hab.tif", sep = ""), 
                  format = "GTiff",overwrite=TRUE)
    }
  } # end of for loop
  names(rast_by_q) <- sort_q # names rasters in list by modeled Q
  out_by_q <- list(rast_by_q, sort_q)
  
  return(out_by_q)
}