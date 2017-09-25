#######################################################################################
#### This function takes hydrology and water quality times series (TS) data with gaps (or not)
#### and creates a new times series at the filling missing data points and/or at new time 
#### resolution, all this by linear interpolation using the approx function in R
####  
#### written by François Birgand, September 2017
####
#### data: dataframe with first column with dates (dd/mm/yyyy hh:mm:ss); as many additional columns
####        as desired.
#### time_interval: time_interval=c(origin_time_res,final_time_res) 
####                for the original and the new time intervals in seconds for the linearized data
####                e.g., c(900,3600) or c(3600,600), to go from 15 min to hourly data or from hourly 
####                to 10-min data
#### bound_dates: bound_dates=c(FALSE,ini_date,final_date)
####              TRUE/FALSE? Need the linear interpolation be started earlier, and end later
####              than the first and last dates in the data?  If TRUE, then provide 
####              the initial (ini_date) and final (final_date) dates to be used
####              ("dd/mm/yyyy hh:mm:ss")
#### writefile=c(FALSE,filename); TRUE/FALSE Need the results be written into a file? If true
####              provide the full name of the file with extension. Date output format is 
####              "yyyy-mm-dd hh:mm:ss"
####
#######################################################################################

lin_interp_fill<-function(data,time_interval=c(origin_time_res,final_time_res),
                          bound_dates=c(FALSE,ini_date,final_date),
                          writefile=c(FALSE,filename)){

Sys.setenv(TZ="GMT",origin = "1970-01-01")
library(tidyverse)
library(dplyr)
library(R.utils)

N<-nrow(data)
data[,1]<-as.POSIXct(strptime(data[,1],format = "%d/%m/%Y %H:%M:%S"))
daterange<-as.POSIXct(strptime(bound_dates[2:3],format = "%d/%m/%Y %H:%M:%S"))
colnames(data)[1]<-"datetime"


##### This section defines the beginning and end date and time for the final time series
##### If the final dates are not different from the original ones, then the ini_date and final_date
##### are chosen from the original file.  If not, the interpolation will be done within the highest 
##### initial  and the lowest final dates, to optimize computational times hence the min() and max() 
##### functions in the else{} statement below
if (bound_dates[1]==FALSE) {ini_date=data[1,1]
                            final_date=data[N,1]
  } else {
   ini_date<-max(daterange[1],data[1,1])
   final_date<-min(daterange[2],data[N,1])
}

######################################################################################################
######    The goal of the next routine is to define the temporary TS with an initial time 
######    and a time resolution that will intersect with the desired final time resolution.
######    Typical example is that the recorded hourly stage or flow time series is taken at 
######    57min 35sec instead of the top of the hour and water quality at 01min 14 sec after the 
######    top of the hour.  This tool allows to create 'rectified' time series synchronized at the
######    top of the hour.  In this particular example, the tool would have to be used twice to make 
######    two time series.
######    Creating a 1-sec temporary TS matrix, then resampled to fit with the desired time resolution
######    and starting times would fit all situations but would require potentially large computational
######    times.  As a result, lots of cases are examined to find ways to find the minimum time resolution
######    that would fit the desired outcomes.
######    Several cases to take into account, 
###### 1. in the original file, the time stamp is not on a rounded second-time (e.g., the 
######    measurements are taken at odd times, and the time stamp in seconds is different than
######    :00, e.g., :57), 
######    OR the final time steps are not a multiple of 1-min.
######    OR the seconds in the time stamp for the new file to be generated are not equal to 0.
######    then, the sub-min time steps are evaluated, trying tom make 30-sec, or 5-sec or 2-sec
######    time steps, and if none of this would work, then make a one-second time stamp.
###### 2. The second stamp is :00, but the minutes are not multiples of 5 min, OR the final time 
######    resolution if not multiples of 5 min OR the beginning of the final file to be created 
######    is not a multiple of 5 min, then We create a 1-min time series 
###### 3. the initial time stamp and final time stamps are multiples of 5 min, then we create a 5 min
######    time series.  This is not necessarily the most efficient on the computation time basis
######    but a 5-min time series is easy to resample and does not take a huge amount of additional
######    computational resources
###### 4. the time_interval of the original and the final files are the same

if (as.POSIXlt(data[1,1])$sec!=0 | time_interval[2]%%60!=0 | 
    (bound_dates[1]==TRUE & as.POSIXlt(daterange[1])$sec!=0)){  ### see case 1.
  if (if (bound_dates[1]==TRUE){as.POSIXlt(data[1,1])$sec%%30==0 & time_interval[2]%%30==0 & 
      as.POSIXlt(daterange[1])$sec%%30==0} else {
        as.POSIXlt(data[1,1])$sec%%30==0 & time_interval[2]%%30==0}){
    nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/30) ### 30-sec file
    compdatetime<-as.POSIXct(ini_date+30*seq(0,nb_inter,1))
    } else {
    if (if (bound_dates[1]==TRUE){as.POSIXlt(data[1,1])$sec%%5==0 & time_interval[2]%%5==0 & 
        as.POSIXlt(daterange[1])$sec%%5==0} else {
          as.POSIXlt(data[1,1])$sec%%5==0 & time_interval[2]%%5==0}){
      nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/5) ### 5-sec file
      compdatetime<-as.POSIXct(ini_date+5*seq(0,nb_inter,1))
      } else {
        if (if (bound_dates[1]==TRUE){as.POSIXlt(data[1,1])$sec%%2==0 & time_interval[2]%%2==0 & 
            as.POSIXlt(daterange[1])$sec%%2==0} else {
              as.POSIXlt(data[1,1])$sec%%2==0 & time_interval[2]%%2==0}){
          nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/2) ### 2-sec file
          compdatetime<-as.POSIXct(ini_date+2*seq(0,nb_inter,1))
        } else {
          nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600)
          compdatetime<-as.POSIXct(ini_date+seq(0,nb_inter,1))  ### 1-sec file
        }
      }
    }
} else {
  if (as.POSIXlt(data[1,1])$min%%5!=0 | time_interval[2]%%300!=0 |
      (bound_dates[1]==TRUE & as.POSIXlt(daterange[1])$min%%5!=0)){
    nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/60)
    compdatetime<-as.POSIXct(ini_date+60*seq(0,nb_inter,1))  ### 1-min file  
  } else {
    if (time_interval[2]!=time_interval[1]){
      ###### defines the number of intervals needed to go from ini_date to final_date
      ###### in case of weird final dates, floor() is used to get a integer multiplier
      nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/60/5)
      ###### creates the final full regular interval date time series
      compdatetime<-as.POSIXct(ini_date+60*5*seq(0,nb_inter,1))   ### 5-min file
    } else {
      nb_inter<-floor(as.numeric(final_date-ini_date)*24*3600/time_interval[2])
      compdatetime<-as.POSIXct(ini_date+time_interval[2]*seq(0,nb_inter,1))
    }
  }
}

compdatetime<-as.data.frame(compdatetime)
colnames(compdatetime)<-"datetime"

  ###### the nice trick here comes from the package dplyr with the function 'left_join'
date()
temp<-left_join(compdatetime,data)
date()
###### need to consider the case where there are NAs for the very first and very last dates
###### the function approx() in the next after next loop ignores terms where there are NAs
###### at the beginning and end of a dataframe. The function seqToIntervals() from the R.utils
###### package is quite handy to dupplicate the closest value to the ends of the dataframe

nn<-as.numeric(rownames(tail(temp,1)))
for (j in 2:dim(temp)[2]){
  if (is.na(temp[1,j])){
    i=2
    while(is.na(temp[i,j])){i=i+1}
    temp[1,j]=temp[i,j]
    }
  if (is.na(temp[nn,j])){
    i=0
    while(is.na(temp[nn-i,j])){i=i+1}
    temp[nn,j]=temp[nn-i,j]
  }
}

##### This is where the magic occurs, using the approx() function.  This function uses only 
##### vectors, so there is a loop to go through all the parameters that need to be linearized
##### approx generates a list of results.  Since the dates in R are handles as the number of 
##### seconds after 1970-01-01 00:00:00, the syntax 
##### is used structure(tempapprox$x,class=c('POSIXt','POSIXct'))
##### the value of 1 in structure(1,class=c('POSIXt','POSIXct')) yields "1970-01-01 00:00:01 GMT"
##### the results are then aggregated in a data frame
tempapprox<-approx(temp[,1],temp[,2], n=nn , yleft = NA, rule = 2:2)
tempTS<-structure(tempapprox$x,class=c('POSIXt','POSIXct'))
tempTS<-data.frame(tempTS,tempapprox$y)

if (dim(temp)[2]>2) {
  for (j in 3:dim(temp)[2]) {
    tempapprox<-approx(temp[,1],temp[,j],n=nn , rule = 2:2)
    tempTS<-data.frame(tempTS,tempapprox$y)
  }
}
names(tempTS)<-names(data)

##### This part defines the desired final date time series final_dateTS with the desired 
##### start and end dates and the desired time interval

if (bound_dates[1]==FALSE) {
  nb_inter = floor(as.numeric(data[N,1]-data[1,1])*24*3600/time_interval[2])
  final_dateTS = as.POSIXct(data[1,1]+time_interval[2]*seq(0,nb_inter,1))
} else {
  nb_inter = floor(as.numeric(daterange[2]-daterange[1])*24*3600/time_interval[2])
  final_dateTS = as.POSIXct(daterange[1]+time_interval[2]*seq(0,nb_inter,1))
}
final_dateTS<-as.data.frame(final_dateTS)
colnames(final_dateTS) = "datetime"
rm(data)
##### The last step is to find the intersection between 
complete_TS<-left_join(final_dateTS,tempTS)
assign("complete_TS",data,env=.GlobalEnv)

if (writefile[1]==TRUE) {write.csv(complete_TS,file = writefile[2],row.names=FALSE)}
  
  
} ### end of function

