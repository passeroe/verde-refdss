# This function will pull in iRIC output results and format them to be rasterized
# Last updated by Elaina Passero 2/22/19

# Requirements for running this code:
# The sequential layers of inundating discharge surfaces has an order that is inherited when it is read in from the directory.
# Therefore, the naming convention of the IRIC output csv files must be such that they are ordered correctl

get.results <- function(wd,reachName){
  
# Set this to the IRIC_Processing_in_R_v1 folder to run this code
setwd(paste(wd,"results","\\",reachName,"\\",sep = "")) # DEM and iRIC calculation results must be in their own folder
# get names of iric output csv files in the working directory
iric_results <- list.files(pattern = ".csv") # working directory cannot contain any csv's besides results

# Create empty list to contain rasters
holdList <- list()
csvList <- list()

# Create list of modeled Qs
modeled_q <- c()
q_i <- sub("Result_","",sub(".csv","",iric_results))
modeled_q <- c(modeled_q,as.numeric(q_i))

csvList <- lapply(iric_results, function(i) read.csv(i,skip = 2,header = TRUE, sep=",",check.names=TRUE))

holdList$csvList <- csvList
holdList$modeled_q <- modeled_q
return(holdList)
} # end of function

