# Filling hydrologic time series that have missing data

This function takes hydrology and water quality times series (TS) data with gaps (or not) and creates a new times series filling in for missing data points and/or at new time resolution, all this by linear interpolation using the *approx()* function in R

## Background
When acquiring hydrologic and water quality time series, it is not rare to have gaps in the record because of an instrument failure, human error, etc.  For water quality records, which in most cases are acquired infrequently, it is sometimes desirable to extrapolate concentration values.  In many cases, the analysis of the data requires to have gap free flow and concentration data, i.e., that there be data at absolutely regular intervals and that there be a flow or concentration data for each interval.  It might also be desirable at times to create, e.g., 10-min data from 12-min original measurements data stream.  This program coded in R allows to do just this.  

## Examples of what it can do

* Create a time series with a perfect sequence of identical time intervals
* Take a 12-min time series and transform it into a, e.g., 15-min time series
* Take a 1-hr resolution time series and make it a 10-min resolution one
  + The final time resolution can be as low as 1-sec, and as high as monthly


## Requirements
The function does need two packages to run:  
library(dplyr)  
library(R.utils)  

### Two files are needed to run the function.  
The first one is the *'launching file'*, where the data can be preprocessed, and where the variables for the function are defined.  This file is the only one, one should have to use.  The second is the function *per se*, where many comments have been added to explain the code.  One should not need to have to change it at all unless one wants to suggest improvements. 


