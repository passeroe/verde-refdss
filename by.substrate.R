# This script is used to get suitable habitat that meets substrate type requirements.
# Currently I am creating fake substrate type files until I have more information.
# Last edited by Elaina Passero on 5/6/19
## Changed for Cherry Creek stuff, need to fix substrate rasterization back to normal

### Begin Function ###
by.substrate <- function(b, goodHabList, sub_allages,wd,reachName,subName){
  pos <- grep(b,names(sub_allages),ignore.case = TRUE)
  subReq <- sub_allages[,pos] # substrate requirement for current lifestage
  subReq <- subReq[!is.na(subReq)] # remove any NA values
  
  goodRast <- goodHabList[[b]] # raster of suitable habitat for current lifestage
  
  subMap <- readOGR(dsn=paste(wd,"results","/",reachName,sep = ""),layer=subName) # read in substrate shapefile
  #rastSubMap <- rasterize(subMap,goodRast,field=subMap["substrate"],fun='first',update=TRUE)
  #rastSubMap <- projectRaster(rastSubMap,goodRast)
  
  # Mask
  bySubBrick <- mask(goodRast,rastSubMap,inverse=TRUE,maskvalue=subReq,updatevalue=NA) # if cells not covered by acceptable substrate or are NA, they are set to NA
  return(bySubBrick)
}
