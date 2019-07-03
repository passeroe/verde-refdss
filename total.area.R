# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 06/04/19

total.area <- function(a,goodHabList,modeled_q,NormalizeByL,reachL,habMets){
b <- goodHabList[[a]]
acceptVal <- length(habMets) # the value of the acceptable cells
## calculate total available habitat area
sumCells <- cellStats(b,stat='sum',na.rm=TRUE)/acceptVal # divide by the acceptVal to get the total number of acceptable cells
cellSize <- xres(b)^2
totArea <- cellSize*sumCells
areaLookTab <- list() 
areaLookTab$discharge <- modeled_q
areaLookTab$totalArea <- totArea
areaLookTab <- as.data.frame(areaLookTab)
areaLookTab <- arrange(areaLookTab,discharge) # puts table in ascending order
if(NormalizeByL == "Yes"){
  areaLookTab$normalizedArea <- areaLookTab$totalArea/reachL # normalize area by reach length
}
return(areaLookTab)
} # end of function
