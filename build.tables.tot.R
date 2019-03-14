# This script will construct suitable habitat area lookup tables for total available habitat only
# It will also export a data frame containing the polygons of suitable habitat area by discharge for later use
# Last edited by Elaina Passero on 3/14/19

build.tables.tot <- function(n,goodPolyList,totAreaList,modeled_q){
  areaLookTab <- data.frame(row.names=modeled_q) # data table to hold total available and effective area
  polyTab <- data.frame(row.names=modeled_q) # data table to hold the Spatial Polygons
  totList <- goodPolyList[[n]]
  areaLookTab$totalArea <- lapply(totList, function(o) {
    if(length(o)>0){gArea(o)} else{0}})
  polyTab$totalArea <- lapply(totList, function(o) {
    if(length(o)>0){gUnaryUnion(o)} else{NULL}})
  areaTabs <- list(polyTab,areaLookTab)
  return(areaTabs)
}