# This script will house inputs and options for making figures for reports. 
# Last edited by Elaina Passero on 1/23/20



reach_wd <- paste(wd,"reaches","/",reach_name,"/",sep = "")
output_name <- load(file=paste(reach_wd,reach_name,"_fish_outputs.rdata",sep="")) # load fish outputs
eval(parse(text=paste("fish_outputs=",output_name)))

scene_fish_out <- list()
scene_fish_out <- lapply(species_list, function(species){ 
  one_spec <- fish_outputs[[species]]
  for(i in 1:length(one_spec)){ # extracts the outputs by species into their own object
    tempobj = one_spec[[i]]
    eval(parse(text=paste(names(one_spec)[[i]],"=tempobj")))
  }
})



# Producing Figures for Chris + Dave

# source("calc.hab.retention.R")
# hab_retention <- lapply(scene_fish_out, habitat.retention())

source("make.temp.figs.R") # makes 10-day minimum monthly time series plots
temp_figs <- lapply(species_list, function(species) make.temp.figs(species,scene_fish_out,scene_list))
names(temp_figs) <- species_list

source("build.10day.tables.R") # currently set up for adults only
ten_day_min_outputs <- lapply(species_list, function(species) build.10day.tables(species,scene_list,scene_fish_out))
names(ten_day_min_outputs) <- species_list

for(f in 1:length(ten_day_min_outputs)){
  species <- species_list[[f]]
  tab <- ten_day_min_outputs[[species]]$sum_all_yrs
  tab_dif <- ten_day_min_outputs[[species]]$sum_all_yrs_dif
  write.csv(tab,file=paste(species,"_10day_min_sum.csv",sep=""))
  write.csv(tab_dif,file=paste(species,"_10day_min_chg.csv",sep=""))
}

source("make.barplots.chg.R")
chg_barplots <- lapply(species_list, function(species) make.barplots.chg(species,ten_day_min_outputs))

source("interp.plot.abbr.R")
scenario <- "baseline"

# annual
inter_plots_ann <- lapply(species_list, function(species) {
  inter_tab <- scene_fish_out[[scenario]][[species]]$inter_tab
  write.csv(inter_tab,file = paste(scenario,"_",species,"_tab.csv",sep=""))
  interp.plot.abbr(inter_tab,NormalizeByL,as.Date("1990-01-01"),as.Date("1990-12-31"),scenario,species)
  ggsave(paste(scenario,"_",species,"_","annual.png",sep=""),width=7, height=5,units = "in")
})
names(inter_plots_ann) <- species_list
inter_plots_ann

# monthly
inter_plots_mon <- lapply(species_list, function(species) {
  inter_tab <- scene_fish_out[[scenario]][[species]]$inter_tab
  interp.plot.abbr(inter_tab,NormalizeByL,as.Date("1990-07-01"),as.Date("1990-08-31"),scenario,species)
  ggsave(paste(scenario,"_",species,"_","monthly.png",sep=""),width=7, height=5,units = "in")
})
names(inter_plots_mon) <- species_list
inter_plots_mon