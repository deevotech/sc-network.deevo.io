#!/bin/bash
# sudo usermod -a -G docker $USER
# then logout and reboot
# in /etc/environment
# GOROOT="/opt/go"
# GOPATH="/opt/gopath"
# source /etc/environment
# and in ~/.profile
# export GOROOT="/opt/go"
# export GOPATH="/opt/gopath"
# PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
cd /home/ubuntu;
sudo curl -O https://dl.google.com/go/go1.10.linux-amd64.tar.gz;
sudo tar -xvf go1.10.linux-amd64.tar.gz;
sudo mv go /opt/;

mkdir -p /opt/gopath/src/github.com/hyperledger
#rm /tmp/hyperledger-fabric-bftsmart.zip;
rm -rf /opt/gopath/src/github.com/hyperledger/fabric;
rm -rf /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart;
#wget https://github.com/datlv/hyperledger-fabric-bftsmart/archive/release-1.1.zip --output-document=/tmp/hyperledger-fabric-bftsmart.zip
#unzip /tmp/hyperledger-fabric-bftsmart.zip -d /opt/gopath/src/github.com/hyperledger/ && \
#mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart-release-1.1 /opt/gopath/src/github.com/hyperledger/fabric && \
sudo apt-get install python-pip
export LC_ALL=C && \
source ~/.bashrc && \
source /etc/environment && \
source ~/.profile;
cd /opt/gopath/src/github.com/hyperledger && \
git clone git@github.com:datlv/hyperledger-fabric-bftsmart.git && \
mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart /opt/gopath/src/github.com/hyperledger/fabric && \
cd /opt/gopath/src/github.com/hyperledger/fabric && \
git checkout release-1.1 && \
git pull && \
cd /opt/gopath/src/github.com/hyperledger/fabric && \
export LC_ALL=C && export GOROOT=/opt/go && GOPATH=/opt/gopath && source /etc/environment && sudo ./devenv/setupUbuntuOnPPC64le.sh;
cd /opt/gopath/src/github.com/hyperledger/fabric && \
export LC_ALL=C && export GOROOT=/opt/go && GOPATH=/opt/gopath && source ~/.profile && source ~/.bashrc && make dist-clean peer;

sudo mkdir -p /var/hyperledger
sudo chmod 777 -R /var/hyperledger