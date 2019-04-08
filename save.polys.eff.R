# This function saves the polygons of effective and total available habitat area in a data frame
# Last edited by Elaina Passero on 3/15/19

save.polys.eff <- function(m, goodPolyList, effAreaList, modeled_q){
  polyTab <- data.frame(modeled_q) # data frame to hold the Spatial Polygons
  colnames(polyTab) <- "discharge"
  totList <- goodPolyList[[m]]
  effList <- effAreaList[[m]]
  polyTab$totalArea <- lapply(totList, function(n) {
    if(length(n)>0){gUnaryUnion(n)} else{NULL}})
  polyTab$effArea <- lapply(effList, function(o) {
    if(length(o)>0){gUnaryUnion(o)} else{NULL}})
  return(polyTab)
}