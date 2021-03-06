# Grad Student Showcase Example
library(ggthemes)
library(extrafont)

plot_long <- plottable %>%
  pivot_longer(2:3,names_to = "species")


hab_mets <- list("Depth","Velocity") #Variables from iRIC calculation result used for habitat analysis - case sensitive
species_list <- c("longfindace","desertsucker")

plt <- ggplot(plot_long)+
  geom_line(aes(x=discharge,y=value,color=species),size=1)+
  theme_gray()+
  theme(text=element_text(family="Times New Roman", size=24,face = "bold"),
        panel.border = element_rect(fill = NA,size=1),
        legend.position = c(0.99,0.99),legend.justification = c("right","top"),
        axis.text.x = element_text(colour = "black",face="plain"),
        axis.text.y = element_text(colour = "black",face="plain"))+
  labs(y=bquote('Total Habitat Area in '~m^2),x=bquote("Discharge in "~m^3/s))+
  scale_colour_manual(values = c("#225731","#195E90"),labels=c("Desert Sucker","Longfin Dace"))+
  scale_x_continuous(breaks=seq(0,1500,300))+
  scale_y_continuous(breaks=seq(0,7500,1500))

plt
# need times font
font_import()
loadfonts(device="win")
fonts()

ggsave("hab_curves.png",plot = plt,dpi=300,width=12,height=6,units = "in")


hydrograph <- na.omit(fread(paste(reach_wd,"flow_scenarios","/","gss_fixed",".csv",sep=""),
                              header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")
if(DateRange=="Yes"){
  hydrograph <- subset(hydrograph, date > as.Date(start_date)) 
  hydrograph <- subset(hydrograph, date < as.Date(end_date))
}

# Create long data frames for plotting
long_tabs <- function(df){
  pivot_longer(df,2:3,names_to = "Metric")
}

lfd_fixed_tab <- fixed_outputs$longfindace$inter_tab$adult %>%
  mutate(species=names(fixed_outputs[1]))
lfd_variable_tab <- variable_outputs$longfindace$inter_tab$adult %>%
  mutate(species=names(variable_outputs[1]))


ds_fixed_tab <- fixed_outputs$desertsucker$inter_tab$adult %>%
  mutate(species=names(fixed_outputs[2]))
ds_variable_tab <- variable_outputs$desertsucker$inter_tab$adult %>%
  mutate(species=names(variable_outputs[2]))

both_f_long <- bind_rows(lfd_fixed_tab,ds_fixed_tab) %>%
  long_tabs(.) %>%
  mutate(Scenario = "Static Flow")
both_v_long <- bind_rows(lfd_variable_tab,ds_variable_tab) %>%
  long_tabs(.) %>%
  mutate(Scenario = "Variable Flow")

all_long <- bind_rows(both_f_long,both_v_long) %>%
  group_by(species) %>%
  group_by(Metric,add=TRUE) %>%
  group_by(Scenario,add = TRUE) %>%
  mutate(day = seq(1,10,1)) %>%
  ungroup() %>%
  select(-date)


# creating some plots
met.labs <- c("Discharge","Total Habitat Area")
names(met.labs) <- c("discharge","total_area")
my_breaks <- function(y) {if (max(y) < 1000) seq(0,1000,200) else seq(0,8000,2000)}

hab_all_plt <- ggplot(all_long)+
  geom_line(data = filter(all_long,Metric=="discharge"),aes(x=day,y=value),size=1)+
  geom_bar(data = filter(all_long,Metric=="total_area"),stat="identity",aes(x=day,y=value,fill=species))+
  theme_gray()+
  theme(text=element_text(family="Times New Roman", size=24,face = "bold",color = "black"),
        panel.border = element_rect(fill = NA,size=1),
        strip.background = element_rect(fill = NA),
        axis.text.x = element_text(colour = "black",face="plain"),
        axis.text.y = element_text(colour = "black",face="plain"))+
  facet_wrap(Metric~Scenario)+
  facet_grid(rows=vars(Metric),cols = vars(Scenario),labeller = labeller(Metric = met.labs),scales = "free_y")+
  scale_y_continuous(breaks = my_breaks)+
  scale_x_continuous(breaks = seq(1,10,1))+
  scale_fill_manual(values = c("#225731","#195E90"),labels=c("Desert Sucker","Longfin Dace"))+
  labs(x="Day",y=NULL)

hab_all_plt

ggsave("tot_hab.png",plot = hab_all_plt,dpi=300,width=12,height=6,units = "in")

sample_hab_map_ds_70 <- fish_outputs$desertsucker$rast_by_q$`70` # map of habitat for desert sucker at 70 CMS

spplot(sample_hab_map)

# Maps of depth, velocity, substrate, and habitat
depth_rast_ds_70 <- depth_rast_ds$layer.20
vel_rast_ds_70 <- vel_rast_ds$layer.20
sub_rast_ds
spplot(depth_rast_ds_70)
spplot(vel_rast_ds_70)
spplot(sub_rast_ds)

writeRaster(depth_rast_ds_70,"depth_rast_ds_70.tif",format="GTiff")
writeRaster(vel_rast_ds_70,"vel_rast_ds_70.tif",format="GTiff")
writeRaster(sub_rast_ds,"sub_rast_ds.tif",format="GTiff")
writeRaster(sample_hab_map_ds_70,"sample_hab_map_ds_70.tif",format="GTiff")


my_lims <- function(y) {if (max(y) <= max(modeled_q)) c(0,max(modeled_q)) else c(0,max(i_tab_all_age$value))}
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
  labs(x="Date",y=NULL)

p_norm




