# This function creates an HSC table for the species of interest
# Last edited by Elaina Passero on 4/26/19

find.hsc <- function(hsc_allspec,species){
  lifeTitle <- unlist(hsc_allspec[,1])
  pos <- grep(species,lifeTitle,ignore.case = TRUE)
  hsc_allages <- hsc_allspec[pos,] # HSC for single species
  return(hsc_allages)
}