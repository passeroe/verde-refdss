# This function will assign exceedance probability on a cell-by-cell basis.
#install.packages("remotes")
#remotes::install_github("mccreigh/rwrfhydro")

# read in historical flow record
hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

# calculate exceedence probability
hydroEP <- data.frame(discharge = hydrograph$discharge,rank=rank(-hydrograph$discharge,ties.method = "min")) # ranks discharges; same values get same ranks
n <- as.numeric(length(hydroEP$discharge))
hydroEP$EP <- hydroEP$rank/(1+n)

# add in modeled discharges and interpolate to get EP's
dfMQ <- data.frame(discharge=modeled_q)
uniqueQ <- bind_rows(hydroEP,data.frame(anti_join(dfMQ["discharge"],hydroEP["discharge"]))) # all discharges that will be in area-lookup table
uniqueQ <- unique(arrange(uniqueQ,discharge)) # puts discharges in ascending order and removes duplicates
intTot <- data.frame(approx(x=uniqueQ$discharge,y=uniqueQ$EP,method="linear",xout=uniqueQ$discharge)) # linearly interpolate for missing total available area values
names(intTot) <- c("discharge","EP")
# Reference dagwood sandwich of inundating Q with EP



# plot FDC to identify the best functions for the tails of the curve
plot_ly(intTot,x=~EP,y=~discharge)


# A slightly different approach using rwrfhydro package --> A little messy and take return period as the INPUT
FDCDF <- CalcFdc(hydrograph,strCol="discharge")
FDCSP <- CalcFdcSpline(FDCDF,strCol = "discharge")


# trying to use a Sasymp
intTot$trialSymp <- SSasymp(intTot$EP,0,1000000,-5.11)

# trying to use NLS
trying <- nls(y~b*x^z,start = list(b = 50, z = -1),data=intTot)