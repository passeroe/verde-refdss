# This script will save fish processing outputs so they can be used in post-processing
# Last edited by Elaina Passero on 10/23/19
reach_name <- "Cherry_Braid"
list.save(outputs,file=paste(reach_wd,reach_name,"_fish_outputs.rdata",sep=""))
output_name <- load(file=paste(reach_wd,reach_name,"_outputs.rdata",sep=""))
eval(parse(text=paste("outputs=",output_name)))


