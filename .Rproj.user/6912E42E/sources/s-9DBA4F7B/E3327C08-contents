# This function will calculate probability of occurrence of vegetation guilds/species from EP
# Last edited by Elaina Passero on 11/20/19

find.prob.occur <- function(v,hydro_ep,one_veg_logit){
  
  nums <- seq(1:(length(one_veg_logit[[1]])-1))
  vars <- paste("B",(nums-1),sep="")
  for(i in 1:length(nums)){
    assign(vars[i],as.numeric(one_veg_logit[i+1,])) 
  }
  
  eqn <- one_veg_logit[1,1] # extract equation from table
  
  for(i in 1:length(var_vals)){chr <- gsub(vars[i],var_vals[i],chr)} # add coefficients to eqn
  
  # evaluate the equation at each EP value
  for(i in 1:length(hydro_ep$EP)){
    x <- hydro_ep$EP[i]
    chr_x <- gsub("*x",paste("*",x,sep=""),chr,fixed=TRUE) # replaces x with EP value
    hydro_ep$prob_v[i] <- eval(parse(text=chr_x))
  }
  return(hydro_ep)
}