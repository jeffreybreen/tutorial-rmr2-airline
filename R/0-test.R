#!/usr/bin/env Rscript

#
# "Example 0" -- square the integers from 1 to 1000
#
# from https://github.com/RevolutionAnalytics/RHadoop/blob/master/rmr2/docs/tutorial.md
#

library(rmr2)

# Set "LOCAL" variable to T to execute using rmr's local backend.
# Otherwise, use Hadoop (which needs to be running, correctly configured, etc.)

LOCAL=T

if (LOCAL) {
	rmr.options(backend = 'local')
} else {
	rmr.options(backend = 'hadoop')
}

small.ints = 1:1000

small.int.path = to.dfs(small.ints)

out = mapreduce(input = small.int.path, map = function(k,v) keyval(v, v^2))

results = from.dfs( out )
results.df = as.data.frame(results, stringsAsFactors=F )

str(results.df)
