#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() {
	echo "Usage: $0 [-g <orgname>] [-n <numberpeer>]" 1>&2
	exit 1
}
while getopts ":g:n:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${n}" ]; then
	usage
fi
ORG=${g}
NUMBER=${n}

source $(dirname "$0")/env.sh
initPeerVars ${ORG} ${NUMBER}
cp /home/ubuntu/hyperledgerconfig/data/ca/rca.${g}.deevo.io.pem /home/ubuntu/hyperledgerconfig/data/orgs/${g}/peer1.${g}.deevo.io/msp/cacerts/
cp ../config-1.2/configtx.yaml ${FABRIC_CFG_PATH}/configtx.yaml
cp ../config-1.2/core.yaml ${FABRIC_CFG_PATH}/core.yaml
mkdir -p data
mkdir -p data/logs
if [ -f ./data/logs/${PEER_NAME}.out ]; then
	rm ./data/logs/${PEER_NAME}.out
fi
if [ -d /var/hyperledger/production ]; then
	rm -rf /var/hyperledger/production/*
fi
# remote data of couchdb
sudo sv stop /etc/service/couchdb
if [ -f /etc/service/couchdb/supervise/lock ]; then
	sudo rm /etc/service/couchdb/supervise/lock
fi
if [ -d /opt/couchdb ]; then
	sudo rm -rf /opt/couchdb
fi
sudo mkdir /opt/couchdb
sudo mkdir /opt/couchdb/data
sudo chmod 777 -R /opt/couchdb
sudo cp ../config-1.2/local.ini /home/couchdb/etc/local.ini
rm -rf /ect/sv/couchdb/log/*

docker image prune -af
chaincodeImages=$(docker images | grep "^dev-peer" | awk '{print $3}')
if [ "$chaincodeImages" != "" ]; then
	# log "Removing chaincode docker images ..."
	docker rmi -f $chaincodeImages
fi
sudo rm -f /home/couchdb/bin/couchdb
sudo cp ./couchdb /home/couchdb/bin/
#sudo runsv /etc/service/couchdb
sudo sv start /etc/service/couchdb
echo $FABRIC_CFG_PATH
sleep 5
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer node start >data/logs/${PEER_NAME}.out 2>&1 &
echo "Success see in data/logs/${PEER_NAME}.out"
