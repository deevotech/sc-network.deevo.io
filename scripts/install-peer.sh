#!/bin/bash
sudo curl -O https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz;
sudo tar -xvf go1.9.1.linux-amd64.tar.gz;
sudo mv go /opt/;

wget https://github.com/datlv/hyperledger-fabric-bftsmart/archive/release-1.1.zip --output-document=/tmp/hyperledger-fabric-bftsmart.zip
unzip /tmp/hyperledger-fabric-bftsmart.zip -d /opt/gopath/src/github.com/hyperledger/ && \
mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart-release-1.1 /opt/gopath/src/github.com/hyperledger/fabric && \
cd /opt/gopath/src/github.com/hyperledger/fabric && \
sudo apt-get install python-pip
export LC_ALL=C
source ~/.bashrc
source /etc/environments
source ~/.profile
export GOROOT=/opt/go && GOPATH=/opt/gopath && source /etc/environments && sudo ./devenv/setupUbuntuOnPPC64le.sh;
export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && source ~/.bashrc && make dist-clean peer configtxgen cryptogen;