# this function will make barplots of % change from baseline for all scenarios on one plot per species
# last edited by Elaina Passero on 12/09/19


make.barplots.chg.os <- function(species,ten_day_min_outputs){
  
  # combine all of the sum_all_yrs_dif tables into 1
  #agg_sum_df <- ten_day_min_outputs[[species]]$sum_all_yrs_dif
   agg_sum_df <- data.frame()
   for(i in 1:length(species_list)){
     next_spec <- ten_day_min_outputs[[i]]$sum_all_yrs_dif %>%
       mutate(species = species_list[[i]])
     agg_sum_df <- bind_rows(agg_sum_df,next_spec)
   }
   agg_sum_df <- agg_sum_df %>%
     filter(scene == "scenario1")
  
  # create plots
  bp <- ggplot(agg_sum_df,aes(x=month,y=per_chg,fill=species))+
    geom_bar(position = "dodge",stat="identity")+
    theme(text=element_text(size=14,face = "bold",color = "black"),
          panel.border = element_rect(fill = NA,size=1),
          strip.background = element_rect(fill = NA),
          axis.text.x = element_text(colour = "black",face="plain"),
          axis.text.y = element_text(colour = "black",face="plain"))+
    labs(y="% Change in Habitat Area",x="Month",title=species)+
    scale_x_continuous(breaks=c(1,2,3,4,5,6,7,8,9,10,11,12),
                       labels = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"))
  ggsave(paste("scenario1","_","per_chg.png",sep=""),width=7, height=5,units = "in")
  return(bp)
}
bp
