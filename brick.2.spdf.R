# Function: Converts Bricks to Spatial Polygons Data Frames
# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 02/20/19

brick.2.spdf <- function(goodHabList){
  goodPolyList <- lapply(goodHabList,rasterToPolygons, dissolve = TRUE)
  # calculate area of polygons
  
  
}