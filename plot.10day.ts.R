# This function will produce 10 day minimum monthly habitat area time series for a single fish species and lifestage.
# All scenarios are displayed on one plot. Note the units of area are assumed to be 
# Last edited by Elaina Passero 6/11/20

plot.10day.ts <- function(a,species,scene_fish_out,scene_list,NormalizeByL,post_tag){
  
  # create table of 10-day minimum habitat area that includes all scenarios
  ten_day_min <- data.frame()
  for(i in 1:length(scene_list)){
    avg_mon_area <- scene_fish_out[[i]][["avg_monthly_area"]][[a]] %>%
      mutate(scene = names(scene_list)[i]) 
      #mutate(scene_name_full = scene_names_full[i])
    ten_day_min <- bind_rows(ten_day_min,avg_mon_area)
  }
  
  # making automatic labeling more readable
  ten_day_min_pt <- ten_day_min %>%
    mutate(fill_date = as.Date(paste(year,"-",month,"-15",sep="")))
  
  if(NormalizeByL == "Yes"){
    # plot time series of 10 day min area
    ts_min_plt <- ggplot(ten_day_min_pt,aes(x=fill_date,y=mon_avg_low_area,color=scene))+
      geom_line()+
      theme_gray()+
      theme(text=element_text(size=12,face = "bold"),
            panel.border = element_rect(fill = NA,size=1),
            legend.justification = c("right","top"),
            axis.text.x = element_text(colour = "black",face="plain",angle = 45,hjust=1),
            axis.text.y = element_text(colour = "black",face="plain"))+
      labs(y=bquote('Minimum 10-day Habitat Area (Normalized)'),x="Year",title=paste(reach_name,", ",names(species),sep=""),color="")+
      scale_x_date(date_labels = "%Y")
  } else{
    # plot time series of 10 day min area
    ts_min_plt <- ggplot(ten_day_min_pt,aes(x=fill_date,y=mon_avg_low_area,color=scene))+
      geom_line()+
      theme_gray()+
      theme(text=element_text(size=12,face = "bold"),
            panel.border = element_rect(fill = NA,size=1),
            legend.justification = c("right","top"),
            axis.text.x = element_text(colour = "black",face="plain",angle = 45,hjust=1),
            axis.text.y = element_text(colour = "black",face="plain"))+
      labs(y=bquote('Minimum 10-day Habitat Area'),x="Year",title=paste(reach_name,", ",name(species),sep=""),color="")+
      scale_x_date(date_labels = "%Y")
  }
  ggsave(paste(reach_wd,"dss_outputs/figures/",post_tag,"_",species,"_",a,"_","10day_hab_ts.jpg",sep=""),
         width=7, height=5,units = "in",dpi = 300)
  return(ts_min_plt)
}



