#!/bin/sh

hadoop fs -mkdir /rhadoop

hadoop fs -mkdir /rhadoop/wordcount
hadoop fs -mkdir /rhadoop/wordcount/data
hadoop fs -put data/hdfs/wordcount/* /rhadoop/wordcount/data

hadoop fs -mkdir /rhadoop/airline
hadoop fs -mkdir /rhadoop/airline/data
hadoop fs -put data/hdfs/airline/* /rhadoop/airline/data
