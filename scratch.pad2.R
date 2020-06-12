# inspect time series to pick example month

baseline <- scene_list$baseline_q
scenario_a <- scene_list$scenario_A
scenario_b <- scene_list$scenario_B

names(scene_names_full) <- scene_names

all_scenes <- bind_rows(scene_list,.id = "Scenario") %>%
  filter(year(date) == 2001) %>%
  mutate(plt_order = ifelse(Scenario == "baseline_q",2,1))



# time series of scenario

plt <- ggplot(all_scenes, aes(x=date,y=discharge,color=reorder(Scenario,plt_order)))+
  geom_line(size=1)+
  theme_few()+
  scale_colour_brewer(palette = "Set1",name="Scenario",labels=scene_names_full)+
  theme(text=element_text(size=14,face = "bold"),
        panel.border = element_rect(fill = NA,size=1),
        legend.position = c("bottom"),
        axis.text.x = element_text(colour = "black",face="plain"),
        axis.text.y = element_text(colour = "black",face="plain"))+
  labs(y=bquote('Discharge '~m^3/s),x=bquote("Date"))

ggsave(paste(reach_wd,"dss_outputs/figures/","sample_ts.jpg",sep=""),
       plot=plt,width=8, height=5,units = "in",dpi = 300)





plot_ly(baseline, x = ~date, y = ~discharge)%>%
  add_trace(y = ~scenario_a$discharge,type = 'scatter', mode = 'lines',name = "A") %>%
  add_trace(y = ~scenario_b$discharge,type = 'scatter', mode = 'lines',name = "B") %>%
  add_trace(type = 'scatter', mode = 'lines',name = "Base")




# getting flow stats from gage
site_id <- '09506000'
pCode <- '00060'
startDate <- "1988-10-22"
endDate <- "2019-9-30"
rawDailyQ <- readNWISdv(site_id,pCode,startDate = startDate,endDate = endDate)

ts.form <- ts.format(rawDailyQ,cols=c(3,4),format = "%Y-%m-%d")
high.spells(ts.form)

mean(ts.form$Q)


# checking A-Q curves
all_a_tab
plot_ly(all_a_tab, x= ~discharge, y= ~normalized_area, linetype = ~species)%>%
  add_trace(type = 'scatter',mode = 'lines')


# checking EP curves
plot_ly(base_hydro_ep, x = ~discharge, y = ~EP)%>%
  add_trace(x=~scenea_hydro_ep$discharge,y = ~scenea_hydro_ep$EP,type = 'scatter', mode = 'lines',name = "A") %>%
  add_trace(x=~sceneb_hydro_ep$discharge,y = ~sceneb_hydro_ep$EP,type = 'scatter', mode = 'lines',name = "B") %>%
  add_trace(type = 'scatter', mode = 'lines',name = "Base")