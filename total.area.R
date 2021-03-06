# Calculates total available habitat area by lifestage
# Last edited by Elaina Passero on 2/19/20

total.area <- function(a,good_hab_list,modeled_q,NormalizeByL,reach_length,hab_mets,ExportTable,fish,reach_run){
  b <- good_hab_list[[a]]
  accept_val <- length(hab_mets) # the value of the acceptable cells
  ## calculate total available habitat area
  sum_cells <- cellStats(b,stat='sum',na.rm=TRUE)/accept_val # divide by the accept_val to get the total number of acceptable cells
  cell_size <- xres(b)^2
  tot_area <- cell_size*sum_cells
  
  area_look_tab <- data.frame(discharge = modeled_q,
                              total_area = tot_area) %>%
    dplyr::arrange(discharge)
  if(NormalizeByL == "Yes"){
    area_look_tab$normalized_area <- area_look_tab$total_area/reach_length # normalize area by reach length
  }
  
  if(ExportTable == "Yes"){
    write.csv(area_look_tab, file = paste(reach_wd, "dss_outputs/",reach_run,"_",fish, "_", a, "_aqlookup.csv", sep = ""))
  }

return(area_look_tab)
} # end of function
