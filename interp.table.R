# This function will add total available and total normalized area (if applicable) to the hydrograph table
# Will use simple linear interpolation to fill in the areas for any discharges not run in iRIC.
# Last updated by Elaina Passero on 5/30/19

interp.table <- function(a,hydrograph,areaLookTab,NormalizeByL){
  aLT <- areaLookTab[[a]]
  uniqueQ <- bind_rows(aLT,data.frame(anti_join(hydrograph["discharge"],aLT["discharge"]))) # all discharges that will be in area-lookup table
  uniqueQ <- unique(arrange(uniqueQ,discharge)) # puts discharges in ascending order and removes duplicates
  intTot <- approx(uniqueQ,method="linear",xout=uniqueQ$discharge) # linearly interpolate for missing total available area values
  if(NormalizeByL=="Yes"){
    intNL <- uniqueQ[,c(1,3)]
    intNL <- approx(intNL,method="linear",xout=uniqueQ$discharge) # linearly interpolate for missing normalized area values
    intUniQ <- data.frame(intTot,intNL[[2]])
    colnames(intUniQ) <- c("discharge","totalArea","normalizedArea")
  } else{
    intUniQ <- data.frame(intTot)
    colnames(intUniQ) <- c("discharge","totalArea")
  }
   hydrograph$totalArea <- intUniQ[match(hydrograph$discharge,intUniQ$discharge),"totalArea"]
  if(NormalizeByL=="Yes"){
    hydrograph$normalizedArea <- intUniQ[match(hydrograph$discharge,intUniQ$discharge),"normalizedArea"]
  }
  hydrograph$normalizedArea[hydrograph$discharge <= min(modeled_q)] <- 0 # 0 area for any discharges below the minimum modeled Q
  return(hydrograph)
}




