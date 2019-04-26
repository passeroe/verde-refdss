# This function pulls substrate requirements for a single species from the substrate table
# Last edited by Elaina Passero on 4/26/19

find.sub <- function(sub_allspec,species){
  colN <- grep(species,names(sub_allspec),ignore.case = TRUE)
  sub_allages <- sub_allspec[,colN]
  return(sub_allages)
}
