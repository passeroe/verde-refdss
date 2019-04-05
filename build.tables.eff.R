# This script will construct suitable habitat area lookup tables when effective area has been calculated
# Last edited by Elaina Passero on 4/4/19

build.tables.eff <- function(j,goodPolyList,effAreaList,modeled_q){
  areaLookTab <- data.frame(modeled_q) # data frame to hold total available and effective area
  colnames(areaLookTab) <- "discharge"
  totList <- goodPolyList[[j]]
  effList <- effAreaList[[j]]
  areaLookTab$totalArea <- unlist(lapply(totList, function(k) {
    if(length(k)>0){gArea(k)} else{0}}))
  areaLookTab$effArea <- unlist(lapply(effList, function(l) {
    if(length(l)>0){gArea(l)} else{0}}))
  return(areaLookTab)
}
