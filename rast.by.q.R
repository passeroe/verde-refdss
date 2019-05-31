# Function: Puts rasters of total available habitat in order of ascending modeled Q's
# Returns a list of rasters
# Last edited by Elaina Passero on 05/13/19

rast.by.q <- function(a,goodHabList,modeled_q){
  if(nlayers(goodHabList[[a]])==0){
    g <- brick(goodHabList[[a]]) # ensures a single raster layer will "unstack"
  } else{
    g <- goodHabList[[a]]
  }
  openBrick <- unstack(g)
  names(openBrick) <- modeled_q
  modeled_q <- sort(modeled_q) # sorts from smallest to largest
  orderByQ <- list()
  for(i in 1:length(modeled_q)){ # builds new list with rasters in ascending order by modeled Q
    n <- which(names(openBrick)==modeled_q[i])
    orderByQ[i] <- openBrick[n]
  } # end of for loop
  names(orderByQ) <- modeled_q # names rasters in list by modeled Q
  return(orderByQ)
}