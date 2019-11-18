# This function removes islands (isolated, small habitat areas) from habitat area calculation and maps
# Last edited by Elaina Passero on 10/18/19

remove.islands <- function(a,good_hab_list,RemoveIslands,island_size){
  if(nlayers(good_hab_list[[a]])==0){
    b <- brick(good_hab_list[[a]]) # ensures a single raster layer will "unstack"
  } else{
    b <- good_hab_list[[a]]
  }
  ## remove islands from rasters using clumping
  if(RemoveIslands == "Yes"){
    u <- unstack(b)
    f <- lapply(u, function(e){
      hab_clump <- clump(e,directions=4) # group raster's into clumps using rook's rules
      clump_freq <- as.data.frame(freq(hab_clump)) # create df of frequencies
      exclude_id <- clump_freq$value[which(clump_freq$count<=island_size)] # find IDs of isolated cells
      e[hab_clump %in% exclude_id] <- NA # Assign NA to all isolated cells
      return(e)
    })
    b <-brick(f)
  } # end of if statement
  return(b)
}

