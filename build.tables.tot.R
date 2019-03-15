# This script will construct suitable habitat area lookup tables for total available habitat only
# It will also export a data frame containing the polygons of suitable habitat area by discharge for later use
# Last edited by Elaina Passero on 3/15/19

build.tables.tot <- function(p,goodPolyList,totAreaList,modeled_q){
  areaLookTab <- data.frame(row.names=modeled_q) # data frame to hold total available and effective area
  polyTab <- data.frame(row.names=modeled_q) # data frame to hold the Spatial Polygons
  totList <- goodPolyList[[p]]
  areaLookTab$totalArea <- lapply(totList, function(q) {
    if(length(q)>0){gArea(q)} else{0}})
  polyTab$totalArea <- lapply(totList, function(q) {
    if(length(q)>0){gUnaryUnion(q)} else{NULL}})
  areaTabs <- list(polyTab,areaLookTab)
  return(areaTabs)
}