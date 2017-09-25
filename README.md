# Filling hydrologic time series that have missing data

This function takes hydrology and water quality times series (TS) data with gaps (or not) and creates a new times series at the filling missing data points and/or at new time resolution, all this by linear interpolation using the approx function in R

## Background
When acquiring hydrologic and water quality time series, it is not rare to have gaps in the record because of an instrument failure, human error, and for water quality, rather infrequent data.  In many cases, the analysis of the data requires to have gap free flow and concentration data, i.e., that there be data at absolutely regular intervals and that there be a flow or concentration data for each interval.  It might also be desirable at times to create 10-min data from 12-min original measurements data stream.  This program coded in R allows to do just this.  

## Requirements
Two files have been written.  One is the function *per se*, where many comments have been added to explain the code.  The second is a 'launching file', where the data can be preprocessed, and where the variables for the function are defined.

The function does need two packages to run: 
library(dplyr)
library(R.utils)
