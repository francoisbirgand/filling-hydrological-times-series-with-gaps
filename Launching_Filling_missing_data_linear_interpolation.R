####################################################################################
###### This is a launching file for the 'filling_missing_data_linear_interpolation'
###### function
######
##### lin_interp_fill(data,
#####                 time_interval=c(origin_time_res,final_time_res),
#####                 bound_dates=c(FALSE,ini_date,final_date),
#####                 writefile=c(FALSE,filename))
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
#### The output of the function is the dataframe 'complete_TS'
####
#### example of what the dataframe must look like to put in the function
#### 
#             datetime         Q        C
#1  01/09/1990 01:00:00       NA       NA
#2  01/09/1990 02:00:00       NA       NA
#3  01/09/1990 03:00:00       NA       NA
#4  01/09/1990 04:00:00       NA       NA
#5  01/09/1990 05:00:00 1074.292 6.774000
#6  01/09/1990 06:00:00 1073.750 6.774000
#7  01/09/1990 07:00:00 1073.208 6.774000
#8  01/09/1990 08:00:00 1072.667 6.774000
#9  01/09/1990 09:00:00 1072.125 6.774000
#####################################################################################

#### some pre-processing is needed.  It is not part of the function because it will probably
#### differ from file to file

path<-("~/gitRepositories/filling-hydrological-times-series-with-gaps/")
filename<-"Elorn_NO3_91-92.csv"
data<-read.csv(file=paste(path,filename,sep=""),sep=",",header = TRUE)

#### the only important name here is 'datetime'.  Make sure it corresponds to the correct column
names(data)<-c("datetime","Q","C")

#### Sometimes the original file the time '00:00:00' does not appear, so this preprocessing is necessary
#### to have it appear
#Date<-substr(data[,1], 1, 10) 
#T<-substr(data[,1], 12, 19)   
#T[T==""]="00:00:00"
#data$datetime<-paste(Date,T,sep=" ")

# with the "Elorn_NO3_91-92.csv", it is daily data only. so there are no "00:00:00" at all, but 
# must added

data$datetime<-paste(as.character(data$datetime),"00:00:00",sep=" ")


#### all the pre-processing has been done and the dataframe called 'data' is now ready
data<-as.data.frame(data)


####################################################################################
##### This defines the variable to put in the function itself
#####
##### lin_interp_fill(data,
#####                 time_interval=c(origin_time_res,final_time_res),
#####                 bound_dates=c(FALSE,ini_date,final_date),
#####                 writefile=c(FALSE,filename))


time_interval<-c(24*3600,3600); bound_dates=c(FALSE,"","")
# time_interval<-c(3600,120); bound_dates=c(TRUE,"01/09/1990 02:20:00","01/09/2003 00:30:00")
filename<-paste(path,"trial.csv",sep="")
writefile=c(TRUE,filename)

source(paste(path,"Function_Filling_missing_data_linear_interpolation.R",sep=""))
date()
lin_interp_fill(data,time_interval,bound_dates,writefile)
date()
