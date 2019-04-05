# This function will add total available and effective area (if applicable) to the hydrograph table
# Interpolation will be used if a function is specified. 
# Last updated by Elaina Passero on 4/4/19

interp.table <- function(t,hydrograph,areaLookTab){
  aLT <- areaLookTab[[t]]
  uniqueQ <- bind_rows(aLT,data.frame(anti_join(hydrograph[1],aLT[1]))) # all discharges that will be in area-lookup table
  uniqueQ <- arrange(uniqueQ,discharge)
  intTot <- approx(uniqueQ,method="linear",xout=uniqueQ$discharge) # linearly interpolate total available area
  if("effArea" %in% names(aLT)){
    intEff <- uniqueQ[1,3]
    intEff <- approx(uniqueQ,method="linear",xout=uniqueQ$discharge)
    intUniQ <- data.frame(intTot,intEff[[2]])
    colnames(intUniQ) <- c("discharge","totalArea","effArea")
  } else{
    intUniQ <- data.frame(intTot)
    colnames(intUniQ) <- c("discharge","totalArea")
  }
   hydrograph$totalArea <- intUniQ[match(hydrograph$discharge,intUniQ$discharge),"totalArea"]
  if("effArea" %in% names(intUniQ)){
    hydrograph$effArea <- intUniQ[match(hydrograph$discharge,intUniQ$discharge),"effArea"]
  }
  return(hydrograph)
}


 

