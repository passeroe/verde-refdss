# Function: Converts Bricks to Spatial Polygons Data Frames
# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 02/26/19

brick.2.spdf <- function(goodHabList){
  goodPolyList <- lapply(goodHabList,rasterToPolygons, dissolve = TRUE)
  # calculate area of polygons
  try1 <- goodHabList[[1]]$cms_1.6 # single raster layer
  try1p <- rasterToPolygons(try1,dissolve=TRUE)
  try1d <- sp::disaggregate(try1p) # each sub-poly becomes its own polygon
  try1d$area <- gArea(try1d,byid=TRUE) # calculate the area for each polygon as a new variable
  try1d <- try1d[try1d$area > 0.25,] # remove polygons that were only one raster cell
  spplot(try1d)

  }



