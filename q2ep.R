
### Using USGS gage data for hydrograph
library(dataRetrieval)
library(nlstools)
##### Flow duration stuff
mysite<-'06752260' # 08263500 (Rio Grande), 06752260 (Cache la Poudre in FoCo), 09506000 (Verde River near Camp Verde), 03171000 (New River at Radford, VA),
# 09380000 (Colorado River DS of Glen Canyon Dam), 09402500 (Colorado River near Grand Canyon)
parameterCd <- "00060"
startDate <- "1950-10-01"
endDate <- "2019-08-31"
dailymean<-readNWISdv(mysite,parameterCd,startDate,endDate)
hydrograph<- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)

# calculate exceedence probability
hydroEP <- data.frame(discharge = hydrograph$discharge,rank=rank(-hydrograph$discharge,ties.method = "min")) # ranks discharges; same values get same ranks
n <- as.numeric(length(hydroEP$discharge))
hydroEP$EP <- hydroEP$rank/(1+n)

### attempt Self-Starting function based on example in Chapter 3 of Nonlinear Regression with R
QEP <- arrange(hydroEP,discharge) %>% 
  top_n(-30) %>% # take highest 30 recorded discharge
  rename(Q=discharge) %>%
  select(Q,EP)

#top_2 <- top_n(QEP,2,Q)
#QEP <- top_n(QEP,-28,Q)

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
extraQ <- data.frame(Q=c(8000,9000,11000,12000,15000))
#extraQ <- data.frame(Q=c(64000,65000,75000,80000,85000))
#extraQ <- data.frame(Q=c(top_2$Q,64000,65000,75000,80000,85000))
#extraQ <- data.frame(Q=c(125000,127000,130000,140000,150000))
extraQ$nlsPredEP <- predict(powCurve,newdata=extraQ)

allHighQ <- full_join(QEP,extraQ)

# ggplot(QEP,aes(x=Q,y=EP))+
#   geom_point()+
#   geom_line(aes(x=Q,y=nlsPredEP))+
#   geom_point(data=extraQ, aes(x=Q,y=nlsPredEP))+
#   geom_line(data=extraQ, aes(x=Q,y=nlsPredEP))+
#   labs(title="Glen Canyon NLS SelfStart Fitted Model")

ggplot(allHighQ)+
  geom_point(aes(x=Q,y=EP,color="Calc EP"))+
  geom_point(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  geom_line(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  theme(legend.title = element_blank())+
  labs(title=paste("Cherry Creek ","Braided", " NLS SelfStart Fitted Model - Pow",sep=""))
  #labs(title=paste("USGS Gage ",mysite, " NLS SelfStart Fitted Model - Pow",sep=""))
  
### Trying to linearize the highest discharges
QEP3 <- subset(hydroEP,EP < 0.0003) %>%
  rename(Q=discharge) %>%
  select(Q,EP)

plot(log(allHighQ$EP),allHighQ$Q)
plot(QEP3$EP,QEP3$Q)


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


##### Trying Exponential Self-Start Model ##### based on Chapter 3 of Nonlinear Regression in R
expMod <- function(Q,b,a) {a*exp(Q/b)} # define exp model
initExp <- function(mCall,data,LHS) { # method for getting initial parameters for exp model
  xy <- sortedXyData(mCall[["Q"]],LHS,data)
  lmFit <- lm(log(xy[, "y"]) ~ xy[, "x"])
  coefs <- coef(lmFit)
  a <- exp(coefs[1])
  b <- 1/coefs[2]
  value <- c(b, a)
  names(value) <- mCall[c("b","a")]
  value
}

SSEXP <- selfStart(expMod, initExp,c("b","a")) # define selfStart model
expCurve <- nls(EP ~ SSEXP(Q,b,a),data=QEP,trace=TRUE,control=nls.control(maxiter=10000)) # generate exp function curve

QEP$nlsPredEP <- predict(expCurve)
extraQ <- data.frame(Q=c(8000,9000,11000,12000,15000))

#extraQ <- data.frame(Q=c(64000,65000,75000,80000,85000))
#extraQ <- data.frame(Q=c(64000,65000,75000,80000,85000))
#extraQ <- data.frame(Q=c(125000,127000,130000,140000,150000))

extraQ$nlsPredEP <- predict(expCurve,newdata=extraQ)

allHighQ <- full_join(QEP,extraQ)
ggplot(allHighQ)+
  geom_point(aes(x=Q,y=EP,color="Calc EP"))+
  geom_point(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  geom_line(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  theme(legend.title = element_blank())+
  #labs(title=paste("USGS Gage ",mysite, " NLS SelfStart Fitted Model - Exp",sep=""))
  labs(title=paste("Cherry Creek ","Braided", " NLS SelfStart Fitted Model - Exp",sep=""))
  #coord_cartesian(ylim=c(0,0.0005))

x <- nlsResiduals(expCurve)
xRes1 <- x$resi1
plot(x$resi1)

p <- nlsResiduals(powCurve)
pRes1 <- p$resi1
plot(p$resi1)

powDiffPredEP <- data.frame(pctChg=(powHighQ1$nlsPredEP-powHighQOG$nlsPredEP)/powHighQOG$nlsPredEP*100,
                            pctDifOG=(powHighQOG$nlsPredEP-powHighQOG$EP)/powHighQOG$EP*100,
                            pctDif1=(powHighQ1$nlsPredEP-powHighQOG$EP)/powHighQOG$EP*100) # percent change

expDiffPredEP <- data.frame(pctChg=(expHighQ1$nlsPredEP-expHighQOG$nlsPredEP)/expHighQOG$nlsPredEP*100,) # percent change

#pResOG,pRes1
#xResOG,xRes1


##### Trying Exponential Self-Start Model with Base 10 ##### based on Chapter 3 of Nonlinear Regression in R
exp10Mod <- function(Q,b,a) {a*(10^(Q/b))} # define exp model
initExp10 <- function(mCall,data,LHS) { # method for getting initial parameters for exp model
  xy <- sortedXyData(mCall[["Q"]],LHS,data)
  lmFit <- lm(log10(xy[, "y"]) ~ xy[, "x"])
  coefs <- coef(lmFit)
  a <- 10^(coefs[1])
  b <- 1/coefs[2]
  value <- c(b,a)
  names(value) <- mCall[c("b","a")]
  value
}

SSEXP10 <- selfStart(exp10Mod, initExp10,c("b","a")) # define selfStart model
exp10Curve <- nls(EP ~ SSEXP10(Q,b,a),data=QEP,trace=TRUE,control=nls.control(maxiter=10000)) # generate exp function curve

QEP$nlsPredEP10 <- predict(exp10Curve)
#extraQ <- data.frame(Q=c(64000,65000,75000,80000,85000))
extraQ <- data.frame(Q=c(64000,65000,75000,80000,85000))
#extraQ <- data.frame(Q=c(125000,127000,130000,140000,150000))
extraQ$nlsPredEP10 <- predict(exp10Curve,newdata=extraQ)
allHighQ <- full_join(QEP,extraQ)
ggplot(allHighQ)+
  geom_point(aes(x=Q,y=EP,color="Calc EP"))+
  geom_point(aes(x=Q,y=nlsPredEP10, color="NLS Pred EP"))+
  geom_line(aes(x=Q,y=nlsPredEP10, color="NLS Pred EP"))+
  theme(legend.title = element_blank())+
  labs(title=paste("USGS Gage ",mysite, " NLS SelfStart Fitted Model - Exp X",sep=""))

x10 <- nlsResiduals(exp10Curve)
x10Res1 <- x10$resi1
plot(x10$resi1)


base10Mod <- function(Q,b,a) {a*(10^(Q*b))}
initbase10 <- function(mCall,data,LHS) {
  xy <- sortedXyData(mCall[["Q"]],LHS,data)
  lmFit <- lm(log10(xy[,"y"])~xy[,"x"])
  coefs <- coef(lmFit)
  a <- 10^coefs[1]
  b <- coefs[2]
  value <- c(a,b)
  names(value) <- mCall[c("a","b")]
  value
}

SS10 <- selfStart(base10Mod,initbase10,c("a","b"))
base10Curve <- nls(EP ~ SS10(Q,b,a),data=QEP,trace=TRUE,control = nls.control(maxiter=10000))
QEP$nlsPredEP10 <- predict(base10Curve)

b10 <- nlsResiduals(base10Curve)
b10Res1 <- b10$resi1
plot(b10$resi1)

#### Trying another method yay :/ - minpack.lm package
# Uses the Levenberg-Marquardt algorithm instead of the Gauss-Newton
library(minpack.lm)
lmTest <- nlsLM(EP ~ SSEXP(Q,a,b),data=QEP,trace=TRUE,control=nls.control(maxiter=10000))
QEP$nlsLMPredEP <- predict(lmTest)
extraQ <- data.frame(Q=c(8000,9000,11000,12000,15000))
extraQ$nlsLMPredEP <- predict(lmTest,newdata=extraQ)
p <- nlsResiduals(lmTest)
pRes1 <- p$resi1
plot(p$resi1)
allHighQ <- full_join(QEP,extraQ)
ggplot(allHighQ)+
  geom_point(aes(x=Q,y=EP,color="Calc EP"))+
  geom_point(aes(x=Q,y=nlsLMPredEP, color="NLS Pred EP"))+
  geom_line(aes(x=Q,y=nlsLMPredEP, color="NLS Pred EP"))+
  theme(legend.title = element_blank())
  #labs(title=paste("USGS Gage ",mysite, " NLS SelfStart Fitted Model - Exp LM",sep=""))
