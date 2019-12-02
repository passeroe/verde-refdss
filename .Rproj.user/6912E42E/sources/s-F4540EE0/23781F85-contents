# this function will make barplots of % change from baseline for all species on one plot
# last edited by Elaina Passero on 12/2/19


make.barplots.chg <- function(species_list,ten_day_min_outputs){
  
  # combine all of the sum_all_yrs_dif tables into 1
  agg_sum_df <- data.frame()
  for(i in 1:length(species_list)){
    next_spec <- ten_day_min_outputs[[i]]$sum_all_yrs_dif %>%
      mutate(species = species_list[[i]])
    agg_sum_df <- bind_rows(agg_sum_df,next_spec)
  }

  # create plots
  bp <- ggplot(agg_sum_df,aes(x=month,y=per_chg,fill=species))+
    geom_bar(stat="identity")
  
bp  
}





