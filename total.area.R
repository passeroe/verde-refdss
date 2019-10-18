# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 10/18/19

total.area <- function(a,good_hab_list,modeled_q,NormalizeByL,reach_length,hab_mets){
b <- good_hab_list[[a]]
accept_val <- length(hab_mets) # the value of the acceptable cells
## calculate total available habitat area
sum_cells <- cellStats(b,stat='sum',na.rm=TRUE)/accept_val # divide by the accept_val to get the total number of acceptable cells
cell_size <- xres(b)^2
tot_area <- cell_size*sum_cells
area_look_tab <- list() 
area_look_tab$discharge <- modeled_q
area_look_tab$total_area <- tot_area
area_look_tab <- as.data.frame(area_look_tab)
area_look_tab <- arrange(area_look_tab,discharge) # puts table in ascending order
if(NormalizeByL == "Yes"){
  area_look_tab$normalized_area <- area_look_tab$total_area/reach_length # normalize area by reach length
}
return(area_look_tab)
} # end of function
