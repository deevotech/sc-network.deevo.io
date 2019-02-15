#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() {
	echo "Usage: $0 [-g <orgname>] [-n <numberpeer>] [-s <run_system_account_or_not>]" 1>&2
	exit 1
}
while getopts ":g:n:s:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	s)
		s=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${n}" ] || [ -z "${s}" ]; then
	usage
fi
ORG=${g}
NUMBER=${n}
SYSACCOUNT=${s}

source $(dirname "$0")/env.sh
initPeerVars ${ORG} ${NUMBER}

# cp ../config/configtx.yaml ${FABRIC_CFG_PATH}/configtx.yaml
if [ ${SYSACCOUNT} -eq 1 ]; then
	cp ../config/core-account.yaml ${FABRIC_CFG_PATH}/core.yaml
else
	cp ../config/core.yaml ${FABRIC_CFG_PATH}/core.yaml
fi

mkdir -p $LOGDIR
if [ -f $LOGDIR/${PEER_NAME}.out ]; then
	rm $LOGDIR/${PEER_NAME}.out
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
sudo chown couchdb:couchdb /opt/couchdb
sudo chmod 777 -R /opt/couchdb
sudo mkdir /opt/couchdb
sudo mkdir /opt/couchdb/data
sudo cp ../config/local.ini /home/couchdb/etc/local.ini
rm -rf /ect/sv/couchdb/log/*

docker image prune -af
chaincodeImages=$(docker images | grep "^dev-peer" | awk '{print $3}')
if [ "$chaincodeImages" != "" ]; then
	# log "Removing chaincode docker images ..."
	docker rmi -f $chaincodeImages
fi

sudo sv start /etc/service/couchdb
echo $FABRIC_CFG_PATH
sleep 5
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer node start >$LOGDIR/${PEER_NAME}.out 2>&1 &
echo "Success see in $LOGDIR/${PEER_NAME}.out"
