# This function will add total available and total normalized area (if applicable) to the hydrograph table
# Will use simple linear interpolation to fill in the areas for any discharges not run in iRIC.
# Last updated by Elaina Passero on 10/18/19

interp.table <- function(a,hydrograph,area_look_tab,NormalizeByL){
  a_l_t <- area_look_tab[[a]]
  unique_q <- a_l_t %>%
    bind_rows(data.frame(anti_join(hydrograph["discharge"],a_l_t["discharge"]))) %>% # all discharges that will be in area-lookup table
    unique(.) %>%
    dplyr::arrange(discharge)
  int_tot <- approx(unique_q,method="linear",xout=unique_q$discharge) # linearly interpolate for missing total available area values
  if(NormalizeByL=="Yes"){
    int_norm_len <- unique_q[,c(1,3)] %>%
      approx(.,method="linear",xout=unique_q$discharge) # linearly interpolate for missing normalized area values
    int_uni_q <- data.frame(int_tot,int_norm_len[[2]])
    colnames(int_uni_q) <- c("discharge","total_area","normalized_area")
  } else{
    int_uni_q <- data.frame(int_tot)
    colnames(int_uni_q) <- c("discharge","total_area")
  }
   hydrograph$total_area <- int_uni_q[match(hydrograph$discharge,int_uni_q$discharge),"total_area"]
  if(NormalizeByL=="Yes"){
    hydrograph$normalized_area <- int_uni_q[match(hydrograph$discharge,int_uni_q$discharge),"normalized_area"]
  }
  return(hydrograph)
}