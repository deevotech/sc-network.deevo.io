#!/bin/bash

sudo apt-get clean
sudo apt-get update -y
sudo apt-get install -y openjdk-8*

sudo update-alternatives --config javac

sudo apt-get update
sudo apt-get install -y ant unzip wget autoconf build-essential libc6-dev-i386
sudo apt-get clean

rm -rf ~/juds
mkdir ~/juds
cd ~/juds

git clone https://github.com/mcfunley/juds

echo $(ls $JAVA_HOME/bin)

cd juds

./autoconf.sh
./configure
make
sudo make install

mkdir -p $GOPATH/src/github.com/hyperledger
rm -rf $GOPATH/src/github.com/hyperledger/fabric-orderingservice

cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/deevotech/fabric-orderingservice -b release-1.4
cd $GOPATH/src/github.com/hyperledger/fabric-orderingservice
ant clean
ant
