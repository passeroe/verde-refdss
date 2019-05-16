# Function: Optionally removes islands (isolated, single cell habitat areas) from habitat area
# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 05/13/19

total.area <- function(a,goodHabList,modeled_q,RemoveIslands,NormalizeByL,reachL){
  if(nlayers(goodHabList[[a]])==0){
    g <- brick(goodHabList[[a]]) # ensures a single raster layer will "unstack"
  } else{
    g <- goodHabList[[a]]
  }
  ## remove islands from rasters using clumping
  if(RemoveIslands == "Yes"){
    u <- unstack(g)
    f <- lapply(u, function(e){
      habClump <- clump(e,directions=4) # group raster's into clumps using rook's rules
      clumpFreq <- as.data.frame(freq(habClump)) # create df of frequencies
      excludeID <- clumpFreq$value[which(clumpFreq$count==2)] # find IDs of isolated cells
      e[habClump %in% excludeID] <- NA # Assign NA to all isolated cells
      return(e)
    })
    b <-brick(f)
  } # end of if statement
  ## calculate total available habitat area
  sumCells <- cellStats(b,stat='sum')
  cellSize <- xres(b)^2
  totArea <- cellSize*sumCells
  areaLookTab <- list() 
  areaLookTab$discharge <- modeled_q
  areaLookTab$totalArea <- totArea
  areaLookTab <- as.data.frame(areaLookTab)
  areaLookTab <- arrange(areaLookTab,discharge) # puts table in ascending order
  if(NormalizeByL == "Yes"){
    areaLookTab$normalizedArea <- areaLookTab$totalArea/reachL # normalize area by reach length ***this isn't correct***
  }
  return(areaLookTab)
} # end of function
