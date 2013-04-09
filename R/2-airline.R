#!/usr/bin/env Rscript

#
# Example 2: airline
#
# Calculate average enroute times by year and market (= airport pair) from the
# airline data set (http://stat-computing.org/dataexpo/2009/the-data.html).
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
	
	# we have smaller extracts of the data in this project's 'local' subdirectory
	hdfs.data.root = 'data/local/airline'
	hdfs.data = file.path(hdfs.data.root, 'data', '20040325-jfk-lax.csv')
		
	hdfs.out.root = hdfs.data.root
	
} else {
	rmr.options(backend = 'hadoop')
	
	# assumes 'airline/data' input path exists on HDFS under /rhadoop-training
	
	hdfs.data.root = '/rhadoop/airline'
	hdfs.data = file.path(hdfs.data.root, 'data')

	# writes output to 'airline' directory in user's HDFS home (e.g., /user/cloudera/airline/)
	hdfs.out.root = 'airline'
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
mapper.year.market.enroute_time = function(key, val.df) {

	# Remove header lines, cancellations, and diversions:
	val.df = subset(val.df, Year != 'Year' & Cancelled == 0 & Diverted == 0)

	# We don't care about direction of travel, so construct a new 'market' vector
	# with airports ordered alphabetically (e.g, LAX to JFK becomes 'JFK-LAX')
	market = with( val.df, ifelse(Origin < Dest, 
								  paste(Origin, Dest, sep='-'),
								  paste(Dest, Origin, sep='-')) )

	# key consists of year, market
	output.key = data.frame(year=as.numeric(val.df$Year), market=market, stringsAsFactors=F)
	
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
reducer.year.market.enroute_time = function(key, val.df) {
	
	output.key = key
	output.val = data.frame(flights = nrow(val.df), 
							scheduled = mean(val.df$scheduled, na.rm=T), 
							actual = mean(val.df$actual, na.rm=T), 
							inflight = mean(val.df$inflight, na.rm=T) )
	
	return( keyval(output.key, output.val) )
}


mr.year.market.enroute_time = function (input, output) {
	mapreduce(input = input,
			  output = output,
			  input.format = asa.csv.input.format,
			  map = mapper.year.market.enroute_time,
			  reduce = reducer.year.market.enroute_time,
			  backend.parameters = list( 
			  	hadoop = list(D = "mapred.reduce.tasks=2") 
			  	),
			  verbose=T)
}

out = mr.year.market.enroute_time(hdfs.data, hdfs.out)

results = from.dfs( out )
results.df = as.data.frame(results, stringsAsFactors=F )
colnames(results.df) = c('year', 'market', 'flights', 'scheduled', 'actual', 'inflight')

print(head(results.df))

# save(results.df, file="out/enroute.time.market.RData")
