# This function saves the polygons of total available habitat area in a data frame
# Last edited by Elaina Passero on 4/8/19

save.polys.tot <- function(r,goodPolyList,totAreaList,modeled_q){
  polyTab <- data.frame(modeled_q) # data frame to hold the Spatial Polygons
  colnames(polyTab) <- "discharge"
  totList <- goodPolyList[[r]]
  areaLookTab$totalArea <- lapply(totList, function(s) {
    if(length(s)>0){gUnaryUnion(s)} else{NULL}})
  return(areaLookTab)
}