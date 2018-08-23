#!/bin/bash
cd /home/ubuntu;
sudo curl -O https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz;
sudo tar -xvf go1.9.1.linux-amd64.tar.gz;
sudo mv go /opt/;

#rm /tmp/hyperledger-fabric-bftsmart.zip;
rm -rf /opt/gopath/src/github.com/hyperledger/fabric-ca;
#wget https://github.com/datlv/hyperledger-fabric-bftsmart/archive/release-1.1.zip --output-document=/tmp/hyperledger-fabric-bftsmart.zip
#unzip /tmp/hyperledger-fabric-bftsmart.zip -d /opt/gopath/src/github.com/hyperledger/ && \
#mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart-release-1.1 /opt/gopath/src/github.com/hyperledger/fabric && \
sudo apt-get install python-pip
export LC_ALL=C && \
source ~/.bashrc && \
source /etc/environment && \
source ~/.profile;
cd /opt/gopath/src/github.com/hyperledger && \
git clone git@github.com:datlv/fabric-ca.git && \
cd /opt/gopath/src/github.com/hyperledger/fabric-ca && \
git checkout release-1.1 && \
git pull;
cp /opt/gopath/src/github.com/deevotech/supply-chain-network/config/version.go /opt/gopath/src/github.com/hyperledger/fabric-ca/lib/metadata/version.go
cd /opt/gopath/src/github.com/hyperledger/fabric-ca && \
export LC_ALL=C && export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && cd cmd/fabric-ca-server && go build;
cd /opt/gopath/src/github.com/hyperledger/fabric-ca && \
export LC_ALL=C && export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && cd cmd/fabric-ca-client && go build;