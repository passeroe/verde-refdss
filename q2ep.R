
### Using USGS gage data for hydrograph
library(dataRetrieval)
##### Flow duration stuff
mysite<-'08263500' # 08263500 (Rio Grande), 06752260 (Cache la Poudre in FoCo), 
parameterCd <- "00060"
startDate <- "1950-10-01"
endDate <- "2018-09-30"
dailymean<-readNWISdv(mysite,parameterCd,startDate,endDate)
hydrograph<- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)

# calculate exceedence probability
hydroEP <- data.frame(discharge = hydrograph$discharge,rank=rank(-hydrograph$discharge,ties.method = "min")) # ranks discharges; same values get same ranks
n <- as.numeric(length(hydroEP$discharge))
hydroEP$EP <- hydroEP$rank/(1+n)

### attempt Self-Starting function based on example in Chapter 3 of Nonlinear Regression with R
QEP <- arrange(hydroEP,discharge) %>% # take highest 30 recorded discharges
  top_n(-30) %>%
  rename(Q=discharge) %>%
  select(Q,EP)

QEP <- subset(hydroEP,EP < 0.0015) %>% # take highest 30 recorded discharges
  #top_n(-30) %>%
  rename(Q=discharge) %>%
  select(Q,EP)

powMod <- function(Q,a,b) {a*Q^b} # define power model
initPow <- function(mCall,data,LHS) { # method for getting initial parameters for power model
  xy <- sortedXyData(mCall[["Q"]],LHS,data)
  lmFit <- lm(log10(xy[, "y"]) ~ log10(xy[, "x"]))
  coefs <- coef(lmFit)
  a <- 10^(coefs[1])
  b <- coefs[2]
  value <- c(b, a)
  names(value) <- mCall[c("b","a")]
  value
}

SSpow <- selfStart(powMod, initPow,c("b","a")) # define selfStart model
powCurve <- nls(EP ~ SSpow(Q,a,b),data=QEP,trace=TRUE,control=nls.control(maxiter=10000)) # generate power function curve
QEP$nlsPredEP <- predict(powCurve)
extraQ <- data.frame(Q=c(60000,65000,70000,75000,80000,85000)) 
extraQ$nlsPredEP <- predict(powCurve,newdata=extraQ)

ggplot(QEP,aes(x=Q,y=EP))+
  geom_point()+
  geom_line(aes(x=Q,y=nlsPredEP))+
  labs(title="Verde at Camp Verde NLS SelfStart Fitted Model")

# add in modeled discharges and interpolate to get EP's
# will linearly interpolate for discharges within the range of observed flows; above max will be calc with SS model
dfMQ <- data.frame(discharge=modeled_q)
uniqueQ <- bind_rows(hydroEP,data.frame(anti_join(dfMQ["discharge"],hydroEP["discharge"]))) # all discharges that will be in area-lookup table
uniqueQ <- unique(arrange(uniqueQ,discharge)) # puts discharges in ascending order and removes duplicates
intTot <- data.frame(approx(x=uniqueQ$discharge,y=uniqueQ$EP,method="linear",xout=uniqueQ$discharge)) # linearly interpolate for missing total available area values
names(intTot) <- c("discharge","EP")
# Reference dagwood sandwich of inundating Q with EP

#-------- Stuff I will probably remove ---------#

# read in historical flow record
hydrograph <- na.omit(fread(paste(wd,reachName,"_hydrograph",".csv",sep=""),header=TRUE, sep = ",",data.table=FALSE))
hydrograph$date <- as.Date(hydrograph$date, format="%m/%d/%Y")

# Selecting the bottom 0.5% to fit a curve through it - power function
backEnd <- subset(hydroEP,hydroEP$EP < 0.005) # take highest 0.5% of recorded discharges

# Taking a swing at GAM
library(mgcv)
gamTest <- data.frame(x=backEnd$discharge,y=backEnd$EP)
#add_row(x=1.5*max(gamTest$x),y=0)
model <- mgcv::gam(y~s(x),data=gamTest)
plot(model)
predictions <- mgcv::predict.gam(model,gamTest)

extraQ <- data.frame(x=c(5000,5500,6000,6500,7000,7500))
extraP <- mgcv::predict.gam(model,extraQ)

ggplot(gamTest, aes(x=x,y=y))+
  geom_point()+
  stat_smooth(method=gam, formula=y~s(x))
