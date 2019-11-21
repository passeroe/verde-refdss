# This function pulls substrate requirements for a single species from the substrate table
# Last edited by Elaina Passero on 10/18/19

find.sub <- function(sub_all_spec,species){
  col_num <- grep(species,names(sub_all_spec),ignore.case = TRUE)
  titles <- names(sub_all_spec)
  sub_all_ages <- sub_all_spec[col_num]
  return(sub_all_ages)
}
