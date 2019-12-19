# The function generates plots of total available and effective habitat area and discharge through the hydrograph
# This time series is for a subset of time
# Last updated by Elaina Passero on 12/05/19

interp.plot.abbr <- function(inter_tab,NormalizeByL,day1,day2,scenario,species){
  
  # one data frame for all lifestages
  if(length(lifestages) > 1){
    i_tab_all_age <- bind_rows(inter_tab,.id = "lifestage") %>%
      pivot_longer()
  } else{
    i_tab_all_age <-inter_tab[[1]] %>%
      mutate(lifestage = lifestages[[1]])
  }
  
  if(NormalizeByL=="Yes"){
    # create longer df
    i_tab_all_age <- i_tab_all_age %>%
      pivot_longer(c(discharge,normalized_area),names_to = "metric") %>%
      filter(date >= day1 & date <= day2)
    
    met.labs <- c("Discharge","Normalized Habitat Area")
    names(met.labs) <- c("discharge","normalized_area")
    my_lims <- function(y) {if (max(y) <= 200) c(0,200) # summer limit
      else c(0,max(i_tab_all_age$value,na.rm = TRUE))}
    
    p_norm <- ggplot(i_tab_all_age)+
      geom_line(data = filter(i_tab_all_age,metric=="discharge"),aes(x=date,y=value))+
      geom_line(data = filter(i_tab_all_age,metric=="normalized_area"),aes(x=date,y=value,linetype=lifestage))+
      theme_gray()+
      theme(text=element_text(size=14,face = "bold",color = "black"),
            panel.border = element_rect(fill = NA,size=1),
            strip.background = element_rect(fill = NA),
            axis.text.x = element_text(colour = "black",face="plain"),
            axis.text.y = element_text(colour = "black",face="plain"))+
      facet_wrap(~metric)+
      facet_grid(rows = vars(metric),labeller = labeller(metric = met.labs),scales = "free_y")+
      scale_y_continuous(limits=my_lims)+
      labs(x="Date",y=NULL,title = paste(scenario," - ",species," ",day1," to ",day2,sep=""))
    
    plt <- list(p_norm)
  } else{
    # create longer df
    i_tab_all_age <- i_tab_all_age %>%
      pivot_longer(c(discharge,total_area),names_to = "metric") %>%
      filter(date >= day1 & date <= day2)
    
    met.labs <- c("Discharge","Total Habitat Area")
    names(met.labs) <- c("discharge","total_area")
    my_lims <- function(y) {if (max(y) <= max(modeled_q)) c(0,max(modeled_q)) 
      else c(0,max(i_tab_all_age$value,na.rm = TRUE))}
    
    p_tot <- ggplot(i_tab_all_age)+
      geom_line(data = filter(i_tab_all_age,metric=="discharge"),aes(x=date,y=value),size=1)+
      geom_line(data = filter(i_tab_all_age,metric=="total_area"),aes(x=date,y=value,linetype=lifestage))+
      theme_gray()+
      theme(text=element_text(size=14,face = "bold",color = "black"),
            panel.border = element_rect(fill = NA,size=1),
            strip.background = element_rect(fill = NA),
            axis.text.x = element_text(colour = "black",face="plain"),
            axis.text.y = element_text(colour = "black",face="plain"))+
      facet_wrap(~metric)+
      facet_grid(rows = vars(metric),labeller = labeller(metric = met.labs),scales = "free_y")+
      scale_y_continuous(limits=my_lims)+
      labs(x="Date",y=NULL,title = paste(scenario," - ",species," ",day1," to ",day2,sep=""))
    
    plt <- list(p_tot)
  }
  
  return(plt)
}
