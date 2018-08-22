#!/bin/bash
sudo apt-get update && \
sudo apt-get install -y openjdk-8-jdk && \
sudo apt-get install -y ant && \
sudo apt-get install -y unzip && \
sudo apt-get install -y wget && \
sudo apt-get install -y libc6-dev-i386 && \
sudo apt-get install -y autoconf && \
sudo apt-get clean && \
sudo rm -rf /var/lib/apt/lists/* && \
sudo rm -rf /var/cache/oracle-jdk8-installer;

sudo apt-get update && \
sudo apt-get install -y ca-certificates-java && \
sudo apt-get clean && \
sudo update-ca-certificates -f && \
sudo rm -rf /var/lib/apt/lists/* && \
sudo rm -rf /var/cache/oracle-jdk8-installer;
	
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
rm /tmp/juds.zip
wget https://github.com/mcfunley/juds/archive/master.zip --output-document=/tmp/juds.zip;

rm -rf /tmp/juds
unzip /tmp/juds.zip -d /tmp/juds && \
cd /tmp/juds/juds-master && \
./autoconf.sh && \
./configure && \
make && \
sudo make install;
sudo mkdir -p /opt && \
sudo mkdir -p /opt/gopath/ && \
sudo chmod 777 -R /opt/gopath && \
mkdir -p /opt/gopath/src && \
mkdir -p /opt/gopath/src/github.com && \
mkdir -p /opt/gopath/src/github.com/hyperledger;
rm /tmp/hyperledger-bftsmart.zip
rm -rf /opt/gopath/src/github.com/hyperledger/hyperledger-bftsmart
wget https://github.com/datlv/hyperledger-fabric-bftsmart/archive/release-1.1.zip --output-document=/tmp/hyperledger-bftsmart.zip
unzip /tmp/hyperledger-bftsmart.zip -d /opt/gopath/src/github.com/hyperledger/ && \
mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart-release-1.1 /opt/gopath/src/github.com/hyperledger/hyperledger-bftsmart && \
cd /opt/gopath/src/github.com/hyperledger/hyperledger-bftsmart && \
ant clean && \
ant;
