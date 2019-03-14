# This script will construct suitable habitat area lookup tables when effective area has been calculated
# It will also export a data frame containing the polygons of suitable habitat area by discharge for later use
# Last edited by Elaina Passero on 3/14/19

build.tables.eff <- function(j,goodPolyList,effAreaList,modeled_q){
  areaLookTab <- data.frame(row.names=modeled_q) # data table to hold total available and effective area
  polyTab <- data.frame(row.names=modeled_q) # data table to hold the Spatial Polygons
  totList <- goodPolyList[[j]]
  effList <- effAreaList[[j]]
  areaLookTab$totalArea <- lapply(totList, function(k) {
    if(length(k)>0){gArea(k)} else{0}})
  polyTab$totalArea <- lapply(totList, function(l) {
    if(length(l)>0){gUnaryUnion(l)} else{NULL}})
  areaLookTab$effArea <- lapply(effList, function(m) {
    if(length(m)>0){gArea(m)} else{0}})
  polyTab$effArea <- lapply(totList, function(n) {
    if(length(n)>0){gUnaryUnion(n)} else{NULL}})
  areaTabs <- list(polyTab,areaLookTab)
  return(areaTabs)
}



