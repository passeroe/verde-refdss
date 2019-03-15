# This function saves the polygons of total available habitat area in a data frame
# Last edited by Elaina Passero on 3/15/19

save.polys.tot <- function(r,goodPolyList,totAreaList,modeled_q){
  polyTab <- data.frame(row.names=modeled_q) # data frame to hold the Spatial Polygons
  totList <- goodPolyList[[r]]
  areaLookTab$totalArea <- lapply(totList, function(s) {
    if(length(s)>0){gArea(s)} else{0}})
  return(areaLookTab)
}