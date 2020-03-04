# This function will produce a stacked barplot to compare scenarios
# Last edited by Elaina Passero on 2/26/20



## build vegetation table

# pull % change
veg_pc_builder <- lapply(veg_list, function(v){
  per_chg_list <- sum_veg_metrics[[v]]$per_chg_hp_tab
})
names(veg_pc_builder) <- veg_list
veg_pc_tab <- bind_rows(veg_pc_builder,.id = "group")

# pull criteria - movement
veg_m_builder <- lapply(veg_list, function(v){
  move_tab <- data.frame(sum_veg_metrics[[v]]$veg_movement) %>%
    select(-baseline_q) %>%
    pivot_longer(everything(),names_to = "scene",values_to = "criteria")
})
names(veg_m_builder) <- veg_list
veg_m_tab <- bind_rows(veg_m_builder,.id = "group")

# add criteria to % change table
veg_summary_tab <- inner_join(veg_pc_tab,veg_m_tab,by=c("group","scene"))


## build fish table

# pull % change
fish_pc_builder <- lapply(species_list, function(species){
  
  one_spec_list <- lapply(lifestages, function(a){ # pull % change tables for all lifestages from a single species
    post_fish_figs[[species]]$ten_day_min_outputs[[a]]$sum_all_yrs_dif
  })
  names(one_spec_list) <- lifestages
  one_spec_df <- bind_rows(one_spec_list,.id = "lifestage") # build single df per species
  return(one_spec_df)
})
names(fish_pc_builder) <- species_list

# add criteria - nativeness
fish_pc_tab <- bind_rows(fish_pc_builder,.id = "species") %>%
  filter(scene != "baseline_q") %>%
  mutate(criteria = ifelse(species %in% native_list,"native","non-native"))

# calculate overall mean percent change in habitat
fish_chg_mean <- fish_pc_tab %>%
  group_by(species) %>%
  group_by(lifestage, add = TRUE) %>%
  group_by(scene, add = TRUE) %>%
  summarise(per_chg = mean(per_chg)) %>%
  mutate(criteria = ifelse(species %in% native_list,"native","non-native")) %>%
  rename(group = species)

## plotting

# plotting fish only - all months
ggplot(data = fish_pc_tab, aes(x = month, y = per_chg, fill = species, alpha= lifestage))+
  geom_bar(stat = "identity",position = "dodge")+
  theme(legend.position = "bottom")+
  facet_wrap(vars(scene),dir = "v")+
  scale_x_continuous(breaks=c(1,2,3,4,5,6,7,8,9,10,11,12),
                     labels = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"))+
  scale_alpha_discrete(range = c(0.35,1))+
  ylab("percent change")


# plotting fish only - mean
ggplot(data = fish_chg_mean, aes(x = reorder(group,per_chg), y = per_chg, fill = criteria, alpha = lifestage))+
  geom_bar(stat = "identity",position = "dodge")+
  coord_flip()+
  theme(legend.position = "bottom")+
  facet_wrap(vars(scene),dir = "v")+
  scale_alpha_discrete(range = c(0.35,1))+
  xlab(element_blank())+
  ylab("percent change")

# plotting vegetation only
ggplot(data = veg_summary_tab, aes(x = reorder(group,per_chg), y = per_chg, fill = criteria))+
  geom_bar(stat = "identity")+
  coord_flip()+
  theme(legend.position = "bottom")+
  facet_wrap(vars(scene),dir = "v")+
  xlab(element_blank())+
  ylab("percent change")



