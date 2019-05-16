# This script is used to get suitable habitat that meets substrate type requirements.
# Currently I am creating fake substrate type files until I have more information.
# Last edited by Elaina Passero on 5/15/19
## Changed for Cherry Creek stuff, need to fix substrate rasterization back to normal

### Begin Function ###
by.substrate <- function(a, goodHabList, sub_allages,wd,reachName,subName){
  pos <- grep(a,names(sub_allages),ignore.case = TRUE)
  subReq <- sub_allages[,pos] # substrate requirement for current lifestage
  subReq <- as.numeric(subReq[!is.na(subReq)]) # remove any NA values
  
  subSeq <- seq(min(subReq),max(subReq)+1,by=1)
  subRC <- data.frame(from=c(-999,subSeq),to=c(subSeq,999))
  subRC$become <- ifelse(subRC$from %in% subReq,1,0)
  rcl <- as.matrix.data.frame(subRC,ncol=3)
  
  goodRast <- goodHabList[[a]] # raster of suitable habitat for current lifestage
  
  subMap <- readOGR(dsn=paste(wd,"results","/",reachName,sep = ""),layer=subName) # read in substrate shapefile
  rastSubMap <- rasterize(subMap,goodRast[[1]],field=subMap@data$substrate,update=TRUE)
  rcSubMap <- reclassify(rastSubMap,rcl,right=FALSE)
  
  # Mask
  bySubBrick <- mask(goodRast,rcSubMap,inverse=TRUE,maskvalue=1,updatevalue=NA) # if cells not covered by acceptable substrate or are NA, they are set to NA
  return(bySubBrick)
}