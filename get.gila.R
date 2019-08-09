# This function will read in the Gila data and add headers to it so I can process them in R

reachName <- "Gila_midreach"

col.names <- c("x", "y", "z", "depth", "velocity", "shear stress", "water surface elevation")

# Set this to the IRIC_Processing_in_R_v1 folder to run this code
tempwd <- paste(wd,"results","/",reachName,"/",sep = "") # DEM and iRIC calculation results must be in their own folder
# get names of iric output csv files in the working directory
srh2d_results <- list.files(path=tempwd,pattern = ".txt") # working directory cannot contain any csv's besides results

# Create empty list to contain rasters
holdList <- list()
csvList <- list()

# Create list of modeled Qs from River2D
modeled_q <- c()
modeled_q <- parse_number(srh2d_results)

csvList <- lapply(srh2d_results, function(i){
  df <- fread(file=paste(wd,"results","/",reachName,"/",i,sep = ""),
        skip = 0,header = FALSE, check.names=FALSE,data.table = FALSE,col.names = col.names)
  return(df)
}) 

names(csvList) <- paste(disunit,"_",modeled_q,sep="")

holdList$csvList <- csvList
holdList$modeled_q <- modeled_q