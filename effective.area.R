# This function will calculate effective area
# Last updated by Elaina Passero on 2/28/19

effective.area <- function(e,goodPolyList){

effTab <- fread(paste(wd,species,"_effrel",".csv",sep=""),header = TRUE,sep = ",")
if (e %in% effTab$primary) {
  ## get the two lifestages from goodPolyList
  prim <- goodPolyList[[e]]
  pos <- as.numeric(which(effTab$primary==e,arr.ind = TRUE)) #gets position of relationship
  ageName <- as.character(effTab[pos,2]) # finds the connect-to lifestage name
  connTo <- goodPolyList[[ageName]]
  ## check for intersection
  checkInt <- mapply(function(i) gIntersects(prim[[i]],connTo[[i]],byid=TRUE,returnDense = FALSE))
  
  checkInt <- list()
  for(i in 1:length(prim)){
    simCT <- gUnaryUnion(connTo[[i]]) # convert polygons into a single object (still has sub-polygons)
    checkInt[[i]] <- gIntersects(prim[[i]],simCT,byid=TRUE,returnDense = TRUE)
  }
  
 simCT <- gUnaryUnion(connTo[[1]])
 checkInt <- gIntersects(prim[[1]],simCT,byid=TRUE,returnDense = FALSE)
  
  ## remove polygons that do not intersect
  
}
  
  
  } # end of function


#spplot(simCT)
#spplot(prim[[4]])
#spplot(connTo[[4]])
