# This function will read in the Gila data and add headers to it so I can process them in R
# last edited by Elaina Passero on 10/21/19

reach_name <- "Gila_midreach"

col_names <- c("x", "y", "z", "depth", "velocity", "shear stress", "water surface elevation")

# Set this to the IRIC_Processing_in_R_v1 folder to run this code
tempwd <- paste(reach_wd,"model_outputs","/",sep = "") # DEM and iRIC calculation results must be in their own folder
# get names of iric output csv files in the working directory
srh2d_results <- list.files(path=tempwd,pattern = ".txt") # working directory cannot contain any txt's besides results

# Create empty list to contain rasters
holdList <- list()
delim_list <- list()

# Create list of modeled Qs from River2D
modeled_q <- c()
modeled_q <- parse_number(srh2d_results)

delim_list <- lapply(srh2d_results, function(i){
  df <- fread(file=paste(tempwd,i,sep = ""),
        skip = 0,header = FALSE, check.names=FALSE,data.table = FALSE,col.names = col_names)
  return(df)
}) 

names(delim_list) <- paste(disunit,"_",modeled_q,sep="")

holdList$delim_list <- delim_list
holdList$modeled_q <- modeled_q