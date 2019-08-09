# This script is where I will work on automating interpolation in the dagwood sandwich layer
interp.dw <- function(outValRast)

depBrick <- outValRast$Depth

for(j in 1:nlayers(depBrick)){
  depBrick[[j]][depBrick[[j]]>0] <- 1 # set wetted areas to 1
  depBrick[[j]] <- depBrick[[j]]*modeled_q[j] # apply discharge value to inundated areas
}

# use cover() function to make layer of inundating discharge
depSand <- depBrick[[1]]

for(j in 1:nlayers(depBrick)){
  depSand <- cover(depSand,depBrick[[j]])
}

# create data frame from raster
rastDF <- as.data.frame(depSand,xy=TRUE,centroids=TRUE,na.rm=TRUE)
names(rastDF) <- c("x","y","z")

# try and do literally anything to interpolate these values
trySOMETHING <- deldir(rastDF,eps=1e-09,digits=4,plotit = TRUE)

# try and use rasterBrick to interpolate in between layers
depBrick <- outValRast$Depth
tryANA <- approxNA(depBrick,method="linear") # each layer in the brick gets interpolated

depList <- unstack(depBrick)
depBoundBrick <- brick(lapply(depList, function(i){boundaries(i,asNA=TRUE)})) # brick of the boundaries
inQBoundBrick <- depBoundBrick*modeled_q # assigns boundaries their inundating discharge

# use cover() function to make layer of inundating discharge
depSand <-inQBoundBrick[[1]]
for(j in 1:nlayers(inQBoundBrick)){
  depSand <- cover(depSand,inQBoundBrick[[j]])
}

# try and use focal for interpolation
r5 <- focal(depSand, w=matrix(1/81,nrow=9,ncol=9),NAonly=TRUE) 