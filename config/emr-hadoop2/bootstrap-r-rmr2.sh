#!/bin/bash

#
# Copyright (c) 2013-2015 by Think Big, a Teradata company
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# bootstrap-r-rmr2.sh is a bootstrap script for Amazon's Elastic MapReduce service.
# By Jeffrey Breen <jeffrey.breen@thinkbiganalytics.com>, and based on work
# in JD Long's segue package, and Antonio Piccobolo's whirr script in RHadoop.
#
# This version is for the more recent AMIs which provide Hadoop 2. Other than Hadoop,
# the major difference is the shift from Debian to Amazon's Red Hat-like Linux.


# turn on logging and exit on error
set -e -x

sudo yum -y install libcurl-devel

# Install rmr2's prerequisite packages from CRAN, plus plyr and some other favorites:
sudo R --no-save << EOF
install.packages(c('RJSONIO', 'itertools', 'digest', 'Rcpp', 'functional', 'httr', 'plyr', 
'stringr', 'reshape2', 'dplyr', 'Hmisc', 'memoise', 'lazyeval', 'caTools', 'rJava', 'R.methodsS3'),
    repos="http://cran.revolutionanalytics.com", INSTALL_opts=c('--byte-compile') )
EOF


# download and install rmr2 from github:

rm -rf RHadoop
mkdir RHadoop
cd RHadoop
curl --insecure -L https://github.com/RevolutionAnalytics/rmr2/releases/download/3.3.1/rmr2_3.3.1.tar.gz | tar zx
sudo R CMD INSTALL --byte-compile rmr2

# sudo su << EOF1 
# echo ' 
# export HADOOP_HOME=/usr/lib/hadoop
# ' >> /etc/profile 
#  
# EOF1
