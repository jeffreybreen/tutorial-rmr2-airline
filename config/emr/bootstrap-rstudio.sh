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


# install RStudio:

sudo sh -c 'echo "HADOOP_HOME=/home/hadoop" >> /etc/R/Renviron.site'
sudo sh -c 'echo "JAVA_HOME=/usr/lib/jvm/java-6-sun" >> /etc/R/Renviron.site'

sudo apt-get -y install gdebi-core

## set hadoop password to "rhadoop" for RStudio login:
sudo sh -c 'echo -e "rhadoop\nrhadoop" | passwd hadoop'

if [ `arch` == "i686" ]
then
    wget http://download2.rstudio.org/rstudio-server-0.98.501-i386.deb
    sudo gdebi -n rstudio-server-0.98.501-i386.deb
else
    wget http://download2.rstudio.org/rstudio-server-0.98.501-amd64.deb
    sudo gdebi -n rstudio-server-0.98.501-amd64.deb
fi

