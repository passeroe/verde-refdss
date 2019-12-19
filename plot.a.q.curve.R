# This function will plot habitat area-discharge curves for all modeled flows
# Last edited by Elaina Passero on 12/09/19

plot.a.q.curve <- function(fish_outputs,species_list,a,NormalizeByL){
  
  # Gather area-lookup tables for lifestage
  tables <- lapply(species_list, function(species){
    fish_outputs[[species]]$area_look_tab[[a]]
  })
  names(tables) <- species_list
  
  all_a_tab <- bind_rows(tables,.id = "species")
  
  if(NormalizeByL == "No"){
    plt <- ggplot(all_a_tab)+
      geom_line(aes(x=discharge,y=total_area,color=species),size=1)+
      theme_gray()+
      theme(text=element_text(size=14,face = "bold"),
            panel.border = element_rect(fill = NA,size=1),
            legend.justification = c("right","top"),
            axis.text.x = element_text(colour = "black",face="plain"),
            axis.text.y = element_text(colour = "black",face="plain"))+
      labs(y=bquote('Total Habitat Area in '~m^2),x=bquote("Discharge in "~m^3/s))
  } else{
    plt <- ggplot(all_a_tab)+
      geom_line(aes(x=discharge,y=normalized_area,color=species),size=1)+
      theme_gray()+
      theme(text=element_text(size=14,face = "bold"),
            panel.border = element_rect(fill = NA,size=1),
            legend.justification = c("right","top"),
            axis.text.x = element_text(colour = "black",face="plain"),
            axis.text.y = element_text(colour = "black",face="plain"))+
      labs(y=bquote('Normalized Habitat Area in '~m^2/km),x=bquote("Discharge in "~m^3/s))
  }
  ggsave(paste(reach_wd,reach_name,"_a_q_curves_","all.png",sep=""),plot=plt,width=7, height=5,units = "in")
  return(plt)
}