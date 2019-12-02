# This is a temporary function will produce 10 day min area time series for single species
# Last edited by Elaina Passero 12/2/19

make.temp.figs <- function(s,scene_fish_out,scene_list){
s <- species_list[[2]]
s_name <- "Desert Sucker"

  # create table of 10-day minimum habitat area that includes both scenarios
  ten_day_min <- data.frame()
  for(i in 1:length(scene_list)){
    avg_mon_area <- scene_fish_out[[i]][[s]][["avg_monthly_area"]][[1]] %>%
      mutate(scene = names(scene_list)[i])
    ten_day_min <- bind_rows(ten_day_min,avg_mon_area)
  }
  
  # this section is broken - adding fill date so I can label by year automatically...
  if(ten_day_min[1]!="name"){
    ten_day_min_pt <- ten_day_min %>%
      rename(year="year(date)",month="month(date)") %>%
      mutate(fill_date = as.Date(paste(year,"-",month,"-15",sep="")))
  } else{
    ten_day_min_pt <- ten_day_min %>%
      mutate(fill_date = as.Date(paste(year,"-",month,"-15",sep="")))
  }

  # plot time series of 10 day min area
  ts_min_plt <- ggplot(ten_day_min_pt,aes(x=fill_date,y=mon_avg_low_area,color=scene))+
    geom_line()+
    theme_gray()+
    theme(text=element_text(size=12,face = "bold"),
          panel.border = element_rect(fill = NA,size=1),
          legend.justification = c("right","top"),
          axis.text.x = element_text(colour = "black",face="plain",angle = 45,hjust=1),
          axis.text.y = element_text(colour = "black",face="plain"))+
    labs(y=bquote('Minimum 10-day Habitat Area in '~m^2),x="Year",title=paste(reach_name,", ",s_name,sep=""),color="")+
    scale_colour_manual(values = c("blue","black"),labels=c("Scenario","Historic"))+
    scale_x_date(date_breaks = "1 year",date_labels = "%Y")
  ts_min_plt

}
  


# Boxplots of habitat distribution by year - ignore for now
hab_by_yr <- data.frame()
for(i in 1:length(scene_list)){
  inter_tab <- scene_fish_out[[i]][[s]][["inter_tab"]][[1]] %>%
    mutate(scene = names(scene_list)[i])
  hab_by_yr <- bind_rows(hab_by_yr,inter_tab)
}




