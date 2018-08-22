#!/bin/bash
wget https://github.com/datlv/fabric-ca/archive/release-1.1.zip --output-document=/tmp/fabric-ca.zip
unzip /tmp/fabric-ca.zip -d /opt/gopath/src/github.com/hyperledger/ && \
mv /opt/gopath/src/github.com/hyperledger/fabric-ca-release-1.1 /opt/gopath/src/github.com/hyperledger/fabric-ca && \
cd /opt/gopath/src/github.com/hyperledger/fabric-ca && \
cd cmd/fabric-ca-server
export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && source ~/.bashrc && go build;
cd ../fabric-ca-client
export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && source ~/.bashrc && go build;