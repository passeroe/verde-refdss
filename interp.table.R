# This function will add total available and effective area (if applicable) to the hydrograph table
# Interpolation will be used if a function is specified. 
# Last updated by Elaina Passero on 3/25/19

interp.table <- function(t,hydrograph,areaLookTab){
  aLT <- areaLookTab[[t]]
  hydrograph$totalArea <- aLT[match(hydrograph$discharge,row.names(aLT)),"totalArea"]
  if("effArea" %in% names(aLT)){
    hydrograph$effArea <- aLT[match(hydrograph$discharge,row.names(aLT)),"effArea"]
  }
  return(hydrograph)
}