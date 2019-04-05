# This script will construct suitable habitat area lookup tables for total available habitat only
# Last edited by Elaina Passero on 4/4/19

build.tables.tot <- function(p,goodPolyList,totAreaList,modeled_q){
  areaLookTab <- data.frame(modeled_q) # data frame to hold total available and effective area
  colnames(areaLookTab) <- "discharge"
  totList <- goodPolyList[[p]]
  areaLookTab$totalArea <- unlist(lapply(totList, function(q) {
    if(length(q)>0){gArea(q)} else{0}}))
  return(areaLookTab)
}