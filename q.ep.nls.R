# This script calculates EP for historic flows and extrapolates EP values 
# for modeled discharges outside the historic range
# Last edited by Elaina Passero on 9/30/19


library(dataRetrieval)
library(dplyr)

# 1) Pull data from USGS gage - ideally has 20+ years on record
mysite<-'09506000' # 08263500 (Rio Grande), 06752260 (Cache la Poudre in FoCo), 09506000 (Verde River near Camp Verde)
parameterCd <- "00060"
startDate <- "1950-10-01"
endDate <- "2018-09-30"
dailymean<-readNWISdv(mysite,parameterCd,startDate,endDate)
hydrograph<- data.frame(date=dailymean$Date, discharge=dailymean$X_00060_00003)

# 2) Calculate exceedence probability
hydroEP <- data.frame(discharge = hydrograph$discharge,rank=rank(-hydrograph$discharge,ties.method = "min")) # ranks discharges; same values get same ranks
n <- as.numeric(length(hydroEP$discharge))
hydroEP$EP <- hydroEP$rank/(1+n)

# 3) Extract the highest X-number of recorded discharges to use in extrpolation
topN <- 20 # take highest 30 recorded discharges
QEP <- arrange(hydroEP,discharge) %>% 
  top_n(-topN) %>% 
  rename(Q=discharge) %>%
  select(Q,EP)

# 4) Setup Self-Start Model (SSM) for Power Function
powMod <- function(Q,a,b) {a*Q^b} # define power model
initPow <- function(mCall,data,LHS) { # method for getting initial parameters for power model
  xy <- sortedXyData(mCall[["Q"]],LHS,data)
  lmFit <- lm(log10(xy[, "y"]) ~ log10(xy[, "x"]))
  coefs <- coef(lmFit)
  a <- 10^(coefs[1])
  b <- coefs[2]
  value <- c(b, a)
  names(value) <- mCall[c("b","a")]
  value }
SSpow <- selfStart(powMod, initPow,c("b","a")) # define selfStart model

# 5) Use SSM to generate power function curve
powCurve <- nls(EP ~ SSpow(Q,a,b),data=QEP,trace=TRUE,control=nls.control(maxiter=10000)) # generate power function curve
QEP$nlsPredEP <- stats::predict(powCurve)

# 6) Use curve generated with SSM to extrapolate EP for extra discharges
extraQ <- data.frame(Q=c(65000,70000,75000,80000,85000)) 
extraQ$nlsPredEP <- predict(powCurve,newdata=extraQ)

# 7) Plot calculated EP values and NLS Predicted EP values
allHighQ <- full_join(QEP,extraQ) # data set of high historic flows and extra discharges with their EP values
ggplot(allHighQ)+
  geom_point(aes(x=Q,y=EP,color="Calc EP"))+
  geom_point(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  geom_line(aes(x=Q,y=nlsPredEP, color="NLS Pred EP"))+
  theme(legend.title = element_blank())+
  labs(title=paste("USGS Gage ",mysite, " NLS SelfStart Fitted Model",sep=""))