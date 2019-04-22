# Function: Optionally removes islands (isolated, single cell habitat areas) from habitat area
# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 04/22/19

total.area <- function(c,goodHabList,modeled_q){
  d <- goodHabList[[c]]
  ## remove islands from rasters using clumping
  if(RemoveIslands == "1"){
    habClump <- clump(d,directions=4) # group raster's into clumps using rook's rules
    clumpFreq <- as.data.frame(freq(habClump)) # create df of frequencies
    excludeID <- clumpFreq$value[which(clumpFreq$count==1)] # find IDs of isolated cells
    d[habClump %in% excludeID] <- NA # Assign NA to all isolated cells
  } # end of if statement
  ## calculate total available habitat area
  sumCells <- cellStats(d,stat='sum')
  cellSize <- xres(d)^2
  totArea <- cellSize*sumCells
  areaLookTab <- list() 
  areaLookTab$discharge <- modeled_q
  areaLookTab$totalArea <- totArea
  areaLookTab <- as.data.frame(areaLookTab)
  areaLookTab <- arrange(areaLookTab,discharge) # puts table in ascending order
} # end of function

