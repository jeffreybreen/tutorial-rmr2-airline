#!/bin/bash

#
# Copyright 2013-2014 by Think Big Analytics
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


# turn on logging and exit on error
set -e -x

sudo tee /etc/apt/sources.list.d/R.list <<EOF

# debian R upgrade
deb http://cran.revolutionanalytics.com/bin/linux/debian squeeze-cran/
deb-src http://cran.revolutionanalytics.com/bin/linux/debian squeeze-cran/
EOF

# add key to keyring
 gpg --keyserver subkeys.pgp.net --recv-key 381BA480
 gpg -a --export 381BA480 > jranke_cran.asc
 sudo apt-key add jranke_cran.asc

sudo apt-get update

# install R using the FRONTEND call to eliminate
# user interactive requests
sudo DEBIAN_FRONTEND=noninteractive apt-get install -t testing --yes --force-yes gcc
sudo DEBIAN_FRONTEND=noninteractive apt-get install -t testing --yes --force-yes r-base
sudo DEBIAN_FRONTEND=noninteractive apt-get install -t testing --yes --force-yes r-base-dev r-cran-hmisc

# RCurl needs curl-config:
sudo DEBIAN_FRONTEND=noninteractive apt-get install -t testing --yes --force-yes libcurl4-openssl-dev

# install littler
sudo apt-get install -t testing littler

# some packages have trouble installing without this link
sudo ln -s /usr/lib/libgfortran.so.3 /usr/lib/libgfortran.so

# for the package update script to run, the hadoop user needs to own the R library
sudo chown -R hadoop /usr/lib/R/library


# Install rmr2's prerequisite packages from CRAN, plus plyr and some other favorites:
sudo R --no-save << EOF
install.packages(c('RJSONIO', 'itertools', 'digest', 'Rcpp', 'functional', 'httr', 'plyr', 'stringr', 'reshape2'),
    repos="http://cran.revolutionanalytics.com", INSTALL_opts=c('--byte-compile') )
EOF


# download and install rmr2 2.3.0 from github:

rm -rf RHadoop
mkdir RHadoop
cd RHadoop
curl --insecure -L https://raw.github.com/RevolutionAnalytics/rmr2/master/build/rmr2_2.3.0.tar.gz | tar zx
sudo R CMD INSTALL --byte-compile rmr2

sudo su << EOF1 
echo ' 
export HADOOP_HOME=/usr/lib/hadoop
' >> /etc/profile 
 
EOF1
