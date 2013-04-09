#!/bin/sh

/bin/rm dist/tutorial-rmr2-airline.zip

/usr/bin/zip dist/tutorial-rmr2-airline.zip \
		R/0-test.R  R/1-wordcount.R \
		R/2-airline.R R/3-join.R \
        data/lookup.csv data/lookup.df.RData \
		data/hdfs/wordcount/all-shakespeare data/hdfs/airline/20040325.csv \
		data/local/wordcount/data/all-shakespeare-1000 data/local/airline/data/20040325-jfk-lax.csv \
		bin/populate.hdfs.sh \
		presentation/tutorial-rmr2-airline.pdf
