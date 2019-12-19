# This function will calculate habitat retention between the historic (baseline) flow and the scenarios
# Last edited by Elaina Passero on 11/18/19

calc.hab.retention <- function(scene_fish_out,scene_list,species_list){
  
}



lfd_10day_h <- scene_fish_out$hydrograph$longfindace$avg_monthly_area$adult
lfd_10day_4 <- scene_fish_out$'4_seasons_test'$longfindace$avg_monthly_area$adult

lfd_10day_dif <- lfd_10day_h %>%
  mutate(retained = (lfd_10day_4$mon_avg_low_area - lfd_10day_h$mon_avg_low_area)/lfd_10day_h$mon_avg_low_area)

retained = (lfd_10day_4$mon_avg_low_area - lfd_10day_h$mon_avg_low_area)/lfd_10day_h$mon_avg_low_area

check1 <- scene_fish_out$`4_seasons_test`$desertsucker$avg_monthly_area
check2 <- scene_fish_out$hydrograph$desertsucker$inter_tab
