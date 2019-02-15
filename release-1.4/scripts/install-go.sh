#!/bin/bash
#

# Install go
sudo apt-get update &&
sudo apt-get -y upgrade &&
sudo curl -O https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
sudo tar -xvf go1.11.1.linux-amd64.tar.gz
sudo rm -rf /opt/go
sudo mv go /opt
sudo mkdir -p /opt/gopath
sudo chmod 777 -R /opt/gopath