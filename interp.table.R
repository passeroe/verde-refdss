# This function will add total available and effective area (if applicable) to the hydrograph table
# Will use simple linear interpolation to fill in the areas for any discharges not run in iRIC.
# Last updated by Elaina Passero on 4/8/19

interp.table <- function(t,hydrograph,areaLookTab){
  aLT <- areaLookTab[[t]]
  uniqueQ <- bind_rows(aLT,data.frame(anti_join(hydrograph[1],aLT[1]))) # all discharges that will be in area-lookup table
  uniqueQ <- arrange(uniqueQ,discharge) # puts discharges in ascending order
  intTot <- approx(uniqueQ,method="linear",xout=uniqueQ$discharge) # linearly interpolate for missing total available area values
  if("effArea" %in% names(aLT)){
    intEff <- uniqueQ[1,3]
    intEff <- approx(uniqueQ,method="linear",xout=uniqueQ$discharge) # linearly interpolate for missing effective area values
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


 

