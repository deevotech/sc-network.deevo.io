#!/bin/bash

rm -rf $GOPATH/src/github.com/hyperledger/fabric-ca
sudo apt-get update
sudo apt-get install -y libtool libltdl-dev unzip
sudo rm -rf /var/cache/apt

# clone and build ca
cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/deevotech/fabric-ca -b release-1.2-deevo

cd $GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client &&
	go build &&
	sudo cp fabric-ca-client /usr/local/bin/
cd $GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-server &&
	go build &&
	sudo cp fabric-ca-server /usr/local/bin/
