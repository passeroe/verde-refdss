# This function will pull in iRIC output results and format them to be rasterized
# Last updated by Elaina Passero 1/13/20

# Requirements for running this code:
# Delimited files must be named with their discharge in the name. Discharge values should be numeric only.

get.results <- function(reach_wd,skip_num,dis_unit){
  
# DEM and iRIC calculation results must be in their own folder
tempwd <- paste(reach_wd,"model_outputs","/",sep = "") 
# get names of iric output csv files in the working directory
iric_results <- list.files(path=tempwd,pattern = ".csv") # model_outputs should not contain any other CSVs

# Create empty list to contain rasters
hold_list <- list()
delim_list <- list()

# Create list of modeled Qs
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

hold_list$delim_list <- delim_list
hold_list$modeled_q <- modeled_q
return(hold_list)
} # end of function

