#!/usr/bin/env Rscript

#
# Example 3: map-side joins
#
# Calculate average enroute times by aircraft manufacturer by merging FAA
# aircraft registration data with the airline data set in the mapper
# (http://stat-computing.org/dataexpo/2009/the-data.html).
#
# Requires rmr2 package (https://github.com/RevolutionAnalytics/RHadoop/wiki).
#
# by Jeffrey Breen <jeffrey.breen@thinkbiganalytics.com>
#

library(rmr2)
library(plyr)

# Set "LOCAL" variable to T to execute using rmr's local backend.
# Otherwise, use Hadoop (which needs to be running, correctly configured, etc.)

LOCAL=T


if (LOCAL)
{
  rmr.options(backend = 'local')
  
  # we have smaller extracts of the data in this project's 'local' directory
  hdfs.data.root = 'data/local/airline'
  hdfs.data = file.path(hdfs.data.root, 'data', '20040325-jfk-lax.csv')
  
  hdfs.out.root = 'data/local/join'
  
} else {
  rmr.options(backend = 'hadoop')
  
  # assumes 'airline/data' input path exists on HDFS under /rhadoop-training
  
  hdfs.data.root = '/rhadoop/airline'
  hdfs.data = file.path(hdfs.data.root, 'data')
  
  # writes output to 'join' directory in user's HDFS home (e.g., /user/cloudera/join/)
  hdfs.out.root = 'join'
}

hdfs.out = file.path(hdfs.out.root, 'out')

#
# asa.csv.input.format() - read CSV data files and label field names
# for better code readability (especially in the mapper)
#
asa.csv.input.format = make.input.format(format='csv', mode='text', streaming.format = NULL, sep=',',
                                         col.names = c('Year', 'Month', 'DayofMonth', 'DayOfWeek',
                                                       'DepTime', 'CRSDepTime', 'ArrTime', 'CRSArrTime',
                                                       'UniqueCarrier', 'FlightNum', 'TailNum',
                                                       'ActualElapsedTime', 'CRSElapsedTime', 'AirTime',
                                                       'ArrDelay', 'DepDelay', 'Origin', 'Dest', 'Distance',
                                                       'TaxiIn', 'TaxiOut', 'Cancelled', 'CancellationCode',
                                                       'Diverted', 'CarrierDelay', 'WeatherDelay',
                                                       'NASDelay', 'SecurityDelay', 'LateAircraftDelay'),
                                         stringsAsFactors=F)

#
# the mapper gets keys and values from the input formatter
# in our case, the key is NULL and the value is a data.frame from read.table()
#
mapper.year.mfr.enroute_time = function(key, val.df) {
  
  # Remove header lines, cancellations, and diversions:
  val.df = subset(val.df, Year != 'Year' & Cancelled == 0 & Diverted == 0)

  # merge in manufacturer data from global "lookup.df":
  val.df = merge(val.df, lookup.df, by.x='TailNum', by.y='n.number')
  
  # key consists of year, manufacturer
  output.key = data.frame(year=as.numeric(val.df$Year), mfr=val.df$mfr, stringsAsFactors=F)
  
  # emit data.frame of gate-to-gate elapsed times (CRS and actual) + time in air
  output.val = val.df[,c('CRSElapsedTime', 'ActualElapsedTime', 'AirTime')]
  colnames(output.val) = c('scheduled', 'actual', 'inflight')
  
  # and finally, make sure they're numeric while we're at it
  output.val = transform(output.val, 
                         scheduled = as.numeric(scheduled),
                         actual = as.numeric(actual),
                         inflight = as.numeric(inflight)
  )
  
  return( keyval(output.key, output.val) )
}



#
# the reducer gets all the values for a given key
# the values (which may be multi-valued as here) come in the form of a data.frame
#
reducer.year.mfr.enroute_time = function(key, val.df) {
  
  output.key = key
  output.val = data.frame(flights = nrow(val.df), 
                          scheduled = mean(val.df$scheduled, na.rm=T), 
                          actual = mean(val.df$actual, na.rm=T), 
                          inflight = mean(val.df$inflight, na.rm=T) )
  
  return( keyval(output.key, output.val) )
}


mr.year.mfr.enroute_time = function (input, output) {
  mapreduce(input = input,
            output = output,
            input.format = asa.csv.input.format,
            map = mapper.year.mfr.enroute_time,
            reduce = reducer.year.mfr.enroute_time,
            backend.parameters = list( 
              hadoop = list(D = "mapred.reduce.tasks=2") 
            ),
            verbose=T)
}


# first, load in lookup.df containing tail number to manufacturer mapping

# NOTE: this data.frame is not on the HDFS and is simply being loaded into our workspace

print(load('data/lookup.df.RData'))

out = mr.year.mfr.enroute_time(hdfs.data, hdfs.out)

results = from.dfs( out )
results.df = as.data.frame(results, stringsAsFactors=F )
colnames(results.df) = c('year', 'mfr', 'flights', 'scheduled', 'actual', 'inflight')

print(head(results.df))

# save(results.df, file="out/enroute.time.market.RData")
