# Function: Converts Bricks to Spatial Polygons Data Frames
# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 03/11/19

brick.2.spdf <- function(c){
  rastList <- unstack(c) # unstack into list by discharge
  spdfList <- lapply(rastList,function(d) {
    if(is.na(maxValue(d))==FALSE){
    disSPDF <- rasterToPolygons(d,dissolve = TRUE)
    disSPDF <- sp::disaggregate(disSPDF) # each sub-poly becomes its own polygon
    disSPDF$area <- gArea(disSPDF,byid=TRUE) # calculate the area for each polygon as a new variable
    disSPDF <- disSPDF[disSPDF$area > 0.25,] # remove polygons that were only one raster cell
    } # end of if statement
  }) # end of lapply expression
  return(spdfList)
}