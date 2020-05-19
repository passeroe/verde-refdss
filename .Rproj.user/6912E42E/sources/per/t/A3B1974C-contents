# This function make changes to the historic flow record by hydroperiod
# Last edited by Elaina Passero 11/18/19

### Define Function
alter.hydrograph <- function(hydrograph_hp,EnforceMed,median_q,fixed_chg,per_chg,hp){
  hydrograph_hp <- hydrograph_hp %>%
    filter(hydroperiod == hp)
  
  if(fixed_chg != 0){
    if(fixed_chg < 0){ # water withdrawn
      if(EnforceMed == "Yes"){
        for(r in 1:length(hydrograph_hp$date)){
          if(hydrograph_hp$discharge[[r]] > median_q){
            hydrograph_hp$revised_q[[r]] <- hydrograph_hp$discharge[[r]]+fixed_chg
          } else{
            hydrograph_hp$revised_q[[r]] <- hydrograph_hp$discharge[[r]]
          }
        }
      } else{
        hydrograph_hp$revised_q <- hydrograph_hp$discharge+fixed_chg
      }
    }
    if(fixed_chg > 0){ # water returned
      if(EnforceMed == "Yes"){
        for(r in 1:length(hydrograph_hp$date)){
          if(hydrograph_hp$discharge[[r]] > median_q){
            hydrograph_hp$revised_q[[r]] <- hydrograph_hp$discharge[[r]]+fixed_chg
          } else{
            hydrograph_hp$revised_q[[r]] <- hydrograph_hp$discharge[[r]]
          }
        }
      } else{
        hydrograph_hp$revised_q <- hydrograph_hp$discharge+fixed_chg
      }
    }
  }
  
  if(per_chg != 0){
    # add or remove percent change in discharge
    if(per_chg < 0){ # flow decreases
      if(EnforceMed == "Yes"){
        for(s in 1:length(hydrograph_hp$date)){
          if(hydrograph_hp$discharge[[s]] > median_q){
            hydrograph_hp$revised_q[[s]] <- hydrograph_hp$discharge[[s]]*(1+per_chg)
          } else{
            hydrograph_hp$revised_q[[s]] <- hydrograph_hp$discharge[[s]]
          }
        }
      } else{
        hydrograph_hp$revised_q <- hydrograph_hp$discharge*(1+per_chg)
      }
    } 
    if(per_chg > 0) { # flow increases
      if(EnforceMed == "Yes"){
        for(s in 1:length(hydrograph_hp$date)){
          if(hydrograph_hp$discharge[[s]] > median_q){
            hydrograph_hp$revised_q[[s]] <- hydrograph_hp$discharge[[s]]*(1+per_chg)
          } else{
            hydrograph_hp$revised_q[[s]] <- hydrograph_hp$discharge[[s]]
          }
        }
      } else{
        hydrograph_hp$revised_q <- hydrograph_hp$discharge*(1+per_chg)
      }
    }
  }
  
  if(fixed_chg !=0 | per_chg !=0){
    hydrograph_hp <- hydrograph_hp %>%
      select(-discharge) %>%
      rename(discharge = revised_q)
  }
  
  hydrograph_hp$discharge[hydrograph_hp$discharge < 0] <- 0
  
  return(hydrograph_hp)
}