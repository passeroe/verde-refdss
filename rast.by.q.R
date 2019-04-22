# Function: Puts rasters of total available habitat in order of ascending modeled Q's
# Returns a list of rasters
# Last edited by Elaina Passero on 4/22/19

rast.by.q <- function(c,goodHabList,modeled_q){
  openBrick <- unstack(goodHabList[[c]])
  names(openBrick) <- modeled_q
  modeled_q <- sort(modeled_q) # sorts from smallest to largest
  orderByQ <- list()
  for(i in 1:length(modeled_q)){ # builds new list with rasters in ascending order by modeled Q
    a <- which(names(openBrick)==modeled_q[i])
    orderByQ[i] <- openBrick[a]
  } # end of for loop
  names(orderByQ) <- modeled_q # names rasters in list by modeled Q
  return(orderByQ)
}