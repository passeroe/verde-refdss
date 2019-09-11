
### Using USGS gage data for hydrograph
##### Flow duration stuff
mysite<-'06752260' # 08263500, 06752260 (Cache la Poudre in FoCo)
parameterCd <- "00060"
startDate <- "1991-10-01"
endDate <- "2018-09-30"
dailymean<-readNWISdv(mysite,parameterCd,startDate,endDate)
hydrograph<- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)

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

# Selecting the bottom 0.5% to fit a curve through it - power function
backEnd <- subset(hydroEP,hydroEP$EP < 0.005)

# Taking a swing at GAM
library(mgcv)
gamTest <- data.frame(x=backEnd$discharge,y=backEnd$EP)
  #add_row(x=1.5*max(gamTest$x),y=0)
model <- mgcv::gam(y~s(x),data=gamTest)
plot(model)
predictions <- mgcv::predict.gam(model,gamTest)

extraQ <- data.frame(x=c(50000,55000,60000,65000,70000,75000))
extraP <- mgcv::predict.gam(model,extraQ) # still returns values from original dataset

ggplot(gamTest, aes(x=x,y=y))+
  geom_point()+
  stat_smooth(method=gam, formula=y~s(x))

### attempt Self-Starting function based on example in Chapter 3 of Nonlinear Regression with R

QEP <- subset(hydroEP,hydroEP$EP < 0.005) %>% # select the highest 0.5% of recorded discharges
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
powCurve <- nls(EP ~ SSpow(Q,a,b),data=QEP,trace=TRUE,max) # generate power function curve
QEP$nlsPredEP <- predict(powCurve)
#extraQ <- data.frame(Q=c(50000,55000,60000,65000,70000,75000)) 
#extraQ$nlsPredEP <- predict(powCurve,newdata=extraQ)

ggplot(QEP,aes(x=Q,y=EP))+
  geom_point()+
  geom_line(aes(x=Q,y=nlsPredEP))+
  labs(title="Cache la Poudre NLS SelfStart Fitted Model")
