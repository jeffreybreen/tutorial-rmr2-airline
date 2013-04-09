#
# debug.log - log given input key,val data to local file in dput() format
#
# one of the challenges of debugging any distributed system is the difficulty in
# capturing values "live". Thanks to dput(), R makes this pretty easy, so if
# things are really going wrong, just call this function at the beginning of 
# your mapper or reducer to see exactly what data it's getting.
#
# WARNING: to call this approach a "blunt instrument" is being generous. As it 
# logs all input to your function, for each call, these files can grow to be
# huge -- and since all writes are appends, they even survive and accumlate 
# across jobs. You have been warned!
#
# fn.name can be the calling function name or some other descriptive label 
# to construct the output file name. By default appends to /tmp/marketing-debug/<fn.name>.dput
#
debug.log <- function (fn.name, k, v, out.dir='/tmp/rhadoop') {
	
	if (!file.exists(out.dir))
		dir.create(out.dir, recursive=T)
	
	f.name = file.path(out.dir, paste(fn.name,'.dput', sep=''))
	
	out = file(f.name, open='at')
	
	cat('key = ', file=out)
	dput(k, file=out )
	cat('val = ', file=out)
	dput(v, file=out )
	cat('\n', file=out)
	
	close(out)
}
