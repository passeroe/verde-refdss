# This function removes islands (isolated, single cell habitat areas) from habitat area
# Last edited by Elaina Passero on 6/4/19

remove.islands <- function(a,goodHabList,RemoveIslands,islandSize){
  if(nlayers(goodHabList[[a]])==0){
    b <- brick(goodHabList[[a]]) # ensures a single raster layer will "unstack"
  } else{
    b <- goodHabList[[a]]
  }
  ## remove islands from rasters using clumping
  if(RemoveIslands == "Yes"){
    u <- unstack(b)
    f <- lapply(u, function(e){
      habClump <- clump(e,directions=4) # group raster's into clumps using rook's rules
      clumpFreq <- as.data.frame(freq(habClump)) # create df of frequencies
      excludeID <- clumpFreq$value[which(clumpFreq$count<=islandSize)] # find IDs of isolated cells
      e[habClump %in% excludeID] <- NA # Assign NA to all isolated cells
      return(e)
    })
    b <-brick(f)
  } # end of if statement
  return(b)
}

