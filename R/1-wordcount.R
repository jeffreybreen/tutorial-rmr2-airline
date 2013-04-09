#!/usr/bin/env Rscript

#
# Example 1: wordcount
#
# Tally the number of occurrences of each word in a text
#
# from https://github.com/RevolutionAnalytics/RHadoop/blob/master/rmr2/docs/tutorial.md
#

library(rmr2)

# Set "LOCAL" variable to T to execute using rmr2's local backend.
# Otherwise, use Hadoop (which needs to be running, correctly configured, etc.)

LOCAL=T

if (LOCAL)
{
	rmr.options(backend = 'local')

	# we have smaller extracts of the data in this project's 'local' subdirectory
	hdfs.data.root = 'data/local/wordcount'
	hdfs.data = file.path(hdfs.data.root, 'data', 'all-shakespeare-1000')
	
	hdfs.out.root = hdfs.data.root
		
} else {
	rmr.options(backend = 'hadoop')

	# assumes 'wordcount/data' input path exists on HDFS under /rhadoop
	hdfs.data.root = '/rhadoop/wordcount'
	hdfs.data = file.path(hdfs.data.root, 'data')
	
	# writes output to 'wordcount' directory in user's HDFS home (e.g., /user/cloudera/wordcount/)
	hdfs.out.root = 'wordcount'
}

hdfs.out = file.path(hdfs.out.root, 'out')


map.wc = function(k,lines) {

	words.list = strsplit(lines, '\\s+')		# use '\\W+' instead to exclude punctuation
	words = unlist(words.list)

	return( keyval(words, 1) )
}

reduce.wc = function(word,counts) {
	
	return( keyval(word, sum(counts)) )
}

wordcount = function (input, output = NULL) {
	mapreduce(input = input ,
			  output = output,
			  input.format = "text",
			  map = map.wc,
			  reduce = reduce.wc,
			  combine = T)}

out = wordcount(hdfs.data, hdfs.out)

results = from.dfs( out )
results.df = as.data.frame(results, stringsAsFactors=F )
colnames(results.df) = c('word', 'count')

head(results.df)
