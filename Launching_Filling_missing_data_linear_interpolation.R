####################################################################################
###### This is a launching file for the 'filling_missing_data_linear_interpolation'
###### function
######
##### lin_interp_fill(data,
#####                 time_interval=c(origin_time_res,final_time_res),
#####                 bound_dates=c(FALSE,ini_date,final_date),
#####                 writefile=c(FALSE,filename))
####
#### data: dataframe with first column with dates (yyyy-mm-dd hh:mm:ss); as many additional columns
####        as desired.
#### time_interval: time_interval=c(origin_time_res,final_time_res) 
####                for the original and the new time intervals in seconds for the linearized data
####                e.g., c(900,3600) or c(3600,600), to go from 15 min to hourly data or from hourly 
####                to 10-min data
#### bound_dates: bound_dates=c(FALSE,ini_date,final_date)
####              TRUE/FALSE? Need the linear interpolation be started earlier, and end later
####              than the first and last dates in the data?  If TRUE, then provide 
####              the initial (ini_date) and final (final_date) dates to be used
####              ("yyyy-mm-dd hh:mm:ss")
#### writefile=c(FALSE,filename); TRUE/FALSE Need the results be written into a file? If true
####              provide the full name of the file with extension. Date output format is 
####              "yyyy-mm-dd hh:mm:ss"
####
#### The output of the function is the dataframe 'complete_TS'
####
#### example of what the dataframe must look like to put in the function
#### 
#            datetime    Q     C
# 1991-09-01 00:00:00 2019 8.581
# 1991-09-02 00:00:00 2009 8.581
# 1991-09-03 00:00:00 1829    NA
# 1991-09-04 00:00:00 1789 8.355
# 1991-09-06 00:00:00 1769 8.806
# 1991-09-07 00:00:00 1759 8.806
#####################################################################################

#### some pre-processing is needed.  It is not part of the function because it will probably
#### differ from file to file

path<-("~/gitRepositories/filling-hydrological-times-series-with-gaps/")
filename<-"Example_input.csv"
data<-read.csv(file=paste(path,filename,sep=""),sep=",",header = TRUE)

#### the only important name here is 'datetime'.  Make sure it corresponds to the correct column
names(data)<-c("datetime","Q","C")

# with the "Elorn_NO3_91-92.csv", 
# 1.The dates are in the format "dd/mm/yyyy", so they must first be transformed into yyyy-mm-dd 
# 2.it is daily data only. so there are no "00:00:00" at all, but 
#    must added

Day<-substr(data$datetime, 1, 2)
Mon<-substr(data$datetime, 4, 5)
Year<-substr(data$datetime, 7, 10)
data$datetime<-paste(Year,"-",Mon,"-",Day,sep="")
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
# time_interval<-c(3600,120); bound_dates=c(TRUE,"1990-09-01 02:20:00","2003-09-01 00:30:00")
filename<-paste(path,"Example_output.csv",sep="")
writefile=c(TRUE,filename)

source(paste(path,"Function_Filling_missing_data_linear_interpolation.R",sep=""))
date()
lin_interp_fill(data,time_interval,bound_dates,writefile)
date()
