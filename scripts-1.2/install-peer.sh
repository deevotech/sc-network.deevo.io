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

sudo apt-get update && \
apt-get install -y ant && \
apt-get install -y unzip && \
apt-get install -y wget && \
apt-get install -y autoconf && \
apt-get install -y build-essential && \
apt-get install -y libc6-dev-i386 && \
apt-get clean;

sudo apt-get update \
        && apt-get install -y apt-utils python-dev \
        && apt-get install -y libsnappy-dev zlib1g-dev libbz2-dev libyaml-dev libltdl-dev libtool libc6 \
        && apt-get install -y python-pip \
        && apt-get install -y tree jq unzip\
        && rm -rf /var/cache/apt;

mkdir -p $GOPATH/src/github.com/hyperledger
rm -rf $GOPATH/src/github.com/hyperledger/fabric
cd $GOPATH/src/github.com/hyperledger

go get github.com/golang/protobuf/protoc-gen-go \
        && go get github.com/kardianos/govendor \
        && go get golang.org/x/lint/golint \
        && go get golang.org/x/tools/cmd/goimports \
        && go get github.com/onsi/ginkgo/ginkgo \
        && go get github.com/axw/gocov/... \
        && go get github.com/client9/misspell/cmd/misspell \
        && go get github.com/AlekSi/gocov-xml

# Clone the Hyperledger Fabric code and cp sample config files
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric

cd $GOPATH/src/github.com/hyperledger 
git clone https://github.com/deevotech/fabric -b release-1.2-deevo

#cp $FABRIC_ROOT/devenv/limits.conf /etc/security/limits.conf
cd $GOPATH/src/github.com/hyperledger/fabric
make dist-clean peer

sudo mkdir -p /var/hyperledger
sudo chmod 777 -R /var/hyperledger
