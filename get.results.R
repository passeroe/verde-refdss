# This function will pull in iRIC output results and format them to be rasterized
# Last updated by Elaina Passero 04/22/19

# Requirements for running this code:
# The sequential layers of inundating discharge surfaces has an order that is inherited when it is read in from the directory.
# Therefore, the naming convention of the IRIC output csv files must be such that they are ordered correctl

get.results <- function(wd,reachName,disunit){
  
# Set this to the IRIC_Processing_in_R_v1 folder to run this code
tempwd <- paste(wd,"results","/",reachName,"/",sep = "") # DEM and iRIC calculation results must be in their own folder
# get names of iric output csv files in the working directory
iric_results <- list.files(path=tempwd,pattern = ".csv") # working directory cannot contain any csv's besides results

# Create empty list to contain rasters
holdList <- list()
csvList <- list()

# Create list of modeled Qs from iRIC
#modeled_q <- c()
#q_i <- sub("Result_","",sub(".csv","",iric_results))
#modeled_q <- c(modeled_q,as.numeric(q_i))

# Create list of modeled Qs from River2D
modeled_q <- c()
modeled_q <- parse_number(iric_results)

csvList <- lapply(iric_results, function(i) fread(file=paste(wd,"results","/",reachName,"/",i,sep = ""),
                                                  skip = 1,header = TRUE, sep=",",check.names=TRUE,data.table = FALSE))
# need to change skip = 1 back to skip = 2 for iRIC
names(csvList) <- paste(disunit,"_",modeled_q,sep="")

holdList$csvList <- csvList
holdList$modeled_q <- modeled_q
return(holdList)
} # end of function

