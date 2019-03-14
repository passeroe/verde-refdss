# This function will calculate effective area
# Last updated by Elaina Passero on 3/11/19

effective.area <- function(e,goodPolyList){

effTab <- fread(paste(wd,species,"_effrel",".csv",sep=""),header = TRUE,sep = ",")
if (e %in% effTab$primary) {
  ## get the two lifestages from goodPolyList
  prim <- goodPolyList[[e]]
  pos <- as.numeric(which(effTab$primary==e,arr.ind = TRUE)) #gets position of relationship
  ageName <- as.character(effTab[pos,2]) # finds the connect-to lifestage name
  connTo <- goodPolyList[[ageName]]
  
  ## check for intersection
  for(i in 1:length(prim)){
    if(length(prim[[i]]) > 0 && length(connTo[[i]]) > 0){ # checks that there was suitable habitat found at discharge for each lifestage
    simCT <- gUnaryUnion(connTo[[i]]) # convert polygons into a single object (still has sub-polygons)
    checkInt <- as.vector(gIntersects(prim[[i]],simCT,byid=TRUE,returnDense = TRUE))
    prim[[i]]$checkInt <- checkInt
    prim[[i]] <- prim[[i]][prim[[i]]$checkInt == TRUE,] # remove polygons that do not intersect connTo
    } # end of if statement
  } # end of for loop
  
} # end of first if statement
return(prim)
} # end of function

