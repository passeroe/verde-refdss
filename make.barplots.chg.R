# this function will make barplots of % change from baseline for all species on one plot
# last edited by Elaina Passero on 5/29/20


make.barplots.chg <- function(a,species,ten_day_min_outputs,post_tag,scene_names_full){
  
  # combine all of the sum_all_yrs_dif tables into 1
  agg_sum_df <- ten_day_min_outputs[[a]]$sum_all_yrs_dif %>%
    filter(scene != "baseline_q")

  comp_names <- scene_names_full[-1] # label scenarios getting compared to baseline
  
  # create plots
  bp <- ggplot(agg_sum_df,aes(x=month,y=per_chg,fill=scene))+
    geom_bar(position = "dodge",stat="identity")+
    theme_few()+
    scale_fill_brewer(palette = "Set1",name="Scenario",labels = comp_names)+
    theme(legend.position = "bottom",
          text=element_text(size=14,face = "bold",color = "black"),
          panel.border = element_rect(fill = NA,size=1),
          strip.background = element_rect(fill = NA),
          axis.text.x = element_text(colour = "black",face="plain"),
          axis.text.y = element_text(colour = "black",face="plain"))+
    labs(y="% Change in Habitat Area",x="Month",title=species,a)+
    scale_x_continuous(breaks=c(1,2,3,4,5,6,7,8,9,10,11,12),
                       labels = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"))
  ggsave(paste(reach_wd,"dss_outputs/figures/",post_tag,"_",species,"_",a,"_","per_chg.png",sep=""),width=7, height=5,units = "in")
return(bp)
}