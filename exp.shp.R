
# Function: Converts Cherry Creek results into shapefiles to go to arcGIS
# Last edited by Elaina Passero on 05/01/19

exp.shp <- function(a,csvList,wd,DEM,reachName,xLoc,yLoc) {
  a <- "velocity"
  shpPath <- "C:/Users/epassero/Desktop/VRDSS/!HoJo-CherryCreekStuff/ArcGISstuff/PresentationLayers_data/site_clip.shp"
  site_clip <-shapefile(shpPath)
  pfolder <- "C:/Users/epassero/Desktop/VRDSS/Delaware_Cherry_doc/CherryCreek_DSS/ModelingOutput/BraidedSite/TIN2grid/"
  afolder <- paste(pfolder,a,sep="")
  for(i in 1:length(csvList)){
    layNames <- names(csvList)
    df <- data.frame(x = csvList[[i]][xLoc],y = csvList[[i]][yLoc],z=csvList[[i]][a])
    spHold <- SpatialPointsDataFrame(data=df,coords=df,proj4string = crs(site_clip))
    tryWrite <- writeOGR(spHold,dsn = afolder,layer=paste("v","_",layNames[i],sep=""),driver="ESRI Shapefile",morphToESRI = TRUE)
  }
}


#afolder <- "C:/Users/epassero/Desktop/VRDSS/Delaware_Cherry_doc/CherryCreek_DSS/ModelingOutput/BraidedSite/TIN2grid/vd_4_8"


