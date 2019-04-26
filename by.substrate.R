# This script is used to get suitable habitat that meets substrate type requirements.
# Currently I am creating fake substrate type files until I have more information.
# Last edited by Elaina Passero on 4/26/19

### Begin Function ###
by.substrate <- function(b, goodHabList, sub_allages){
  # create fake substrate layer; process is different depending on which dataset you are running
  fakeSub <- iricValRast[[1]]$cms_0.67# looking at depth
  fSub <- c(0,0.5,0, 0.5,0.6,1, 0.6,0.7,2, 0.7,0.8,3, 0.8,999,4) # arbitrarily creating reclassification criteria
  rcFSMat <- matrix(fSub,ncol=3,byrow=TRUE)
  fakeSub <- reclassify(fakeSub,rcFSMat)
  
  # Sets cells with unacceptable substrate types to NA and acceptable types to 1
  subTab <- subTab[!is.na(subTab)] # remove any NA values
  fakeSub[fakeSub != subTab] <- NA
  fakeSub[fakeSub == subTab] <- 1

  # Mask
  bySubBrick <- mask(hhList,fakeSub,maskvalue=NA,updatevalue=NA) # if cells not covered by acceptable substrate or are NA, they are set to NA
  return(bySubBrick)
}
