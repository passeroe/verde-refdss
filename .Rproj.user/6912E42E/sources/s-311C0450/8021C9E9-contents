# This function will pull in iRIC output results and format them to be rasterized
# Last updated by Elaina Passero 10/21/19

# Requirements for running this code:
# The sequential layers of inundating discharge surfaces has an order that is inherited when it is read in from the directory.
# Therefore, the naming convention of the IRIC output csv files must be such that they are ordered correctly

get.results <- function(reach_wd,skip_num,dis_unit){
  
# Set this to the IRIC_Processing_in_R_v1 folder to run this code
tempwd <- paste(reach_wd,"model_outputs","/",sep = "") # DEM and iRIC calculation results must be in their own folder
# get names of iric output csv files in the working directory
iric_results <- list.files(path=tempwd,pattern = ".csv") # working directory cannot contain any csv's besides results

# Create empty list to contain rasters
holdList <- list()
delim_list <- list()

# Create list of modeled Qs from River2D
modeled_q <- c()
modeled_q <- parse_number(iric_results)

delim_list <- lapply(iric_results, function(i){
  df <- fread(file=paste(tempwd,i,sep = ""),
        skip = skip_num,header = TRUE, sep=",",check.names=TRUE,data.table = FALSE)
  cn <- colnames(df)
  colnames(df) <- word(gsub("[.]"," ",cn)) # removes periods from DF column names and leaves only first word
  return(df)
}) 

names(delim_list) <- paste(dis_unit,"_",modeled_q,sep="")

holdList$delim_list <- delim_list
holdList$modeled_q <- modeled_q
return(holdList)
} # end of function

