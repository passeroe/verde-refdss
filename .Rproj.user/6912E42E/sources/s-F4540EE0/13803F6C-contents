# this function will calculate EP for flows in flow scenario and those above it
# If flows above the range of the flow scenario are input, EP will be calculated from Weibull plotting position assuming 1 event per Q
# Last edited by Elaina Passero 10/29/19

q.ep.weibull <- function(hydrograph, modeled_q){
  
  # Calculate exceedence probability for flows in scenario
  flow_scene_ep <- data.frame(discharge = hydrograph["discharge"],q_rank=rank(-hydrograph["discharge"],ties.method = "min")) # ranks discharges; same values get same ranks
  n <- as.numeric(length(flow_scene_ep$discharge))
  flow_scene_ep$EP <- flow_scene_ep$q_rank/(1+n)
  
  df_m_q <- data.frame(discharge=modeled_q) %>%
    filter(discharge < max(hydrograph$discharge)) # modeled discharges within range of flow scenario
  
  hydro_ep <- bind_rows(flow_scene_ep,data.frame(anti_join(df_m_q["discharge"],flow_scene_ep["discharge"]))) %>%
    arrange(discharge) %>%
    distinct()
  
  hydro_ep <- data.frame(approx(x=hydro_ep$discharge,y=hydro_ep$EP,method="linear",xout=hydro_ep$discharge)) %>%
    dplyr::rename(discharge = x, EP = y)
 
  # sets EP for 0 to 1 if 0 was included in the analysis
   if(min(hydro_ep$discharge) == 0){
    hydro_ep[1,2] <- 1
  } 
  
  # Calculalte EP for flows larger than flow scenario. Assuming 1 event per flow.
  if(any(modeled_q < min(hydrograph$discharge))){
    df_m_q_smaller <- data.frame(discharge=modeled_q) %>%
      filter(discharge < min(hydrograph$discharge)) %>% # modeled discharges below range of flow scenario
      mutate(EP = 1) # sets EP 
    
    hydro_ep <- hydro_ep %>%
      filter(discharge > min(hydrograph$discharge)) %>%
      bind_rows(df_m_q_smaller) %>% # join extra flows and their EP values to flow scenario
      dplyr::arrange(discharge) 
  
  }
  
  
  # Calculalte EP for flows larger than flow scenario. Assuming 1 event per flow.
  if(isTRUE(modeled_q > max(hydrograph$discharge))){
    df_m_q_larger <- data.frame(discharge=modeled_q) %>%
      filter(discharge > max(hydrograph$discharge)) %>% # modeled discharges above range of flow scenario
      mutate(q_rank = rank(-df_m_q_larger$discharge,ties.method = "min")) %>%
      mutate(EP = q_rank/(1+n+length(df_m_q_larger)))
    
    
    hydro_ep <- bind_rows(hydro_ep,df_m_q_larger) %>% # join extra flows and their EP values to flow scenario
      select(-q_rank)
  }
  
  return(hydro_ep)
}
