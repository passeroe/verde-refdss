# This script will construct suitable habitat area lookup tables when effective area has been calculated
# Last edited by Elaina Passero on 3/15/19

build.tables.eff <- function(j,goodPolyList,effAreaList,modeled_q){
  areaLookTab <- data.frame(row.names=modeled_q) # data frame to hold total available and effective area
  totList <- goodPolyList[[j]]
  effList <- effAreaList[[j]]
  areaLookTab$totalArea <- lapply(totList, function(k) {
    if(length(k)>0){gArea(k)} else{0}})
  areaLookTab$effArea <- lapply(effList, function(l) {
    if(length(l)>0){gArea(l)} else{0}})
  return(areaLookTab)
}
