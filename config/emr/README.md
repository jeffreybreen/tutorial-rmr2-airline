Launching Hadoop on AWS using Elastic MapReduce
===============================================

First, download and configure the `elastic-mapreduce` CLI:  http://aws.amazon.com/developertools/2264

This command will set up a 1-node Hadoop cluster, and install R, rmr2, and RStudio:

```
elastic-mapreduce --create --alive --name 'RHadoop tutorial' --hive-interactive --instance-group master --instance-type m1.large --instance-count 1 --debug --visible-to-all-users true --bootstrap-action s3://thinkbig-rhadoop/bootstrap/bootstrap-r-rmr2.sh --bootstrap-action s3://thinkbig-rhadoop/bootstrap/bootstrap-rstudio.sh
```

The `--bootstrap-action` flag is especially useful. It allows you to specify the location of a bash script to run after Hadoop is installed, but before it is run, so you can even upgrade components of Hadoop itself.
