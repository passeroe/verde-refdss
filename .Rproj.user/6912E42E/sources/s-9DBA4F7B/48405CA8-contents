# This function creates an HSC table for the species of interest
# Last edited by Elaina Passero on 4/26/19

find.hsc <- function(hsc_all_spec,species){
  life_title <- unlist(hsc_all_spec[,1])
  pos <- grep(species,life_title,ignore.case = TRUE)
  hsc_all_ages <- hsc_all_spec[pos,] # HSC for single species
  return(hsc_all_ages)
}