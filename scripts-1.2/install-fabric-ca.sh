#!/bin/bash
cd /home/ubuntu;
sudo curl -O https://dl.google.com/go/go1.10.linux-amd64.tar.gz;
sudo tar -xvf go1.10.linux-amd64.tar.gz;
sudo mv go /opt/;

#rm /tmp/hyperledger-fabric-bftsmart.zip;
rm -rf $GOPATH/src/github.com/hyperledger/fabric-ca;
#wget https://github.com/datlv/hyperledger-fabric-bftsmart/archive/release-1.1.zip --output-document=/tmp/hyperledger-fabric-bftsmart.zip
#unzip /tmp/hyperledger-fabric-bftsmart.zip -d /opt/gopath/src/github.com/hyperledger/ && \
#mv /opt/gopath/src/github.com/hyperledger/hyperledger-fabric-bftsmart-release-1.1 /opt/gopath/src/github.com/hyperledger/fabric && \
sudo apt-get update \
        && apt-get install -y libtool libltdl-dev unzip \
        && rm -rf /var/cache/apt

# clone and build ca
cd $GOPATH/src/github.com/hyperledger \
    && wget -O $GOPATH/src/github.com/hyperledger/fabric-ca.zip https://github.com/deevotech/fabric-ca/archive/release-1.2-deevo.zip \
    && unzip fabric-ca.zip \
    && rm fabric-ca.zip \
    && mv fabric-ca-release-1.2-deevo fabric-ca
# This will install fabric-ca-server and fabric-ca-client into $GOPATH/bin/
    # && go install -ldflags "-X github.com/hyperledger/fabric-ca/lib/metadata.Version=$PROJECT_VERSION -linkmode external -extldflags '-static -lpthread'" github.com/hyperledger/fabric-ca/cmd/... 
# Copy example ca and key files
    # && cp $FABRIC_CA_ROOT/images/fabric-ca/payload/*.pem $FABRIC_CA_HOME/
cd $GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client \
    && go build \
    && sudo cp fabric-ca-client /usr/local/bin/ 
cd $GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-server \
    && go build \
    && sudo cp fabric-ca-server /usr/local/bin/