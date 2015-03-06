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


# This version is for the more recent AMIs which provide Hadoop 2. Other than Hadoop,
# the major difference is the shift from Debian to Amazon's Red Hat-like Linux.


sudo /usr/sbin/adduser rstudio
sudo sh -c 'echo -e "rstudio\nrstudio" | passwd rstudio'

sudo sh -c 'echo "HADOOP_HOME=/home/hadoop" >> /usr/lib64/R/etc/Renviron'
sudo sh -c 'echo "HADOOP_CMD=/home/hadoop/bin/hadoop" >> /usr/lib64/R/etc/Renviron'
sudo sh -c 'echo "HADOOP_STREAMING=/home/hadoop/contrib/streaming/hadoop-streaming.jar" >> /usr/lib64/R/etc/Renviron'
sudo sh -c 'echo "JAVA_HOME=/usr/java/latest" >> /usr/lib64/R/etc/Renviron'


sudo yum -y install openssl098e

if [ `arch` == "i686" ]
then
    wget http://download2.rstudio.org/rstudio-server-0.98.1102-i686.rpm
    sudo yum -y install --nogpgcheck rstudio-server-0.98.1102-i686.rpm
else
    wget http://download2.rstudio.org/rstudio-server-0.98.1102-x86_64.rpm
    sudo yum -y install --nogpgcheck rstudio-server-0.98.1102-x86_64.rpm

fi

# fix temp file permissions error when kicking off MapReduce job from rmr:

sudo chmod 777 /mnt/var/lib/hadoop/tmp
# sudo -u hadoop /home/hadoop/bin/hadoop fs -chmod -R 777 /tmp/hadoop-yarn
