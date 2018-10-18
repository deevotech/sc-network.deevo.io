#!/bin/bash

sudo apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer;

sudo apt-get update -y && \
apt-get install -y default-jre && \
apt-get install -y default-jdk && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer;

sudo update-alternatives --config javac

#ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
#RUN export JAVA_HOME

sudo apt-get update && \
apt-get install -y ant && \
apt-get install -y unzip && \
apt-get install -y wget && \
apt-get install -y autoconf && \
apt-get install -y build-essential && \
apt-get install -y libc6-dev-i386 && \
apt-get clean;

#ENV GOPATH /go
mkdir -p $GOPATH/src/github.com/hyperledger
cd $GOPATH/src/github.com/hyperledger

wget https://github.com/mcfunley/juds/archive/master.zip --output-document=/tmp/juds.zip;

echo $(ls $JAVA_HOME/bin)

unzip /tmp/juds.zip -d /tmp/juds;
cd /tmp/juds/juds-master;
cd /tmp/juds/juds-master && \
./autoconf.sh && \
./configure && \
make && \
make install;
rm -rf /tmp/juds.zip
rm -rf /tmp/juds

wget https://github.com/deevotech/fabric-orderingservice/archive/release-1.2-deevo.zip --output-document=/tmp/fabric-orderingservice.zip
unzip /tmp/fabric-orderingservice.zip -d $GOPATH/src/github.com/hyperledger/
mv $GOPATH/src/github.com/hyperledger/fabric-orderingservice-release-1.2-deevo $GOPATH/src/github.com/hyperledger/fabric-orderingservice
cd $GOPATH/src/github.com/hyperledger/fabric-orderingservice && \
ant clean && \
ant;
rm -rf /tmp/fabric-orderingservice.zip;

