#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
SDIR=$(dirname "$0")
source $SDIR/env.sh
usage() { echo "Usage: $0 [-g <orgname>] [-r <restart>]" 1>&2; exit 1; }
while getopts ":g:r:" o; do
    case "${o}" in
        g)
            g=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ] || [ -z "${r}" ] ; then
    usage
fi
source $(dirname "$0")/env.sh
set -e
export FABRIC_CA_SERVER_HOME=$HOME/fabric-ca
export FABRIC_CA_SERVER_TLS_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=rca.${g}.deevo.io
export FABRIC_CA_SERVER_CSR_HOSTS=rca.${g}.deevo.io
export FABRIC_CA_SERVER_DEBUG=true
export BOOTSTRAP_USER_PASS=rca-${g}-admin:rca-${g}-adminpw
export TARGET_CERTFILE=$DATA/${g}-ca-cert.pem
export FABRIC_CA_SERVER_CA_NAME=rca.${g}.deevo.io
export FABRIC_ORGS="ordering-nodes org0 org1 org2 org3 org4 org5"
export FABRIC_CA_SERVER_TLS_CERTFILE=/etc/hyperledger/fabric-ca-server-config/rca.ordering.bft-cert.pem
export FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/rca.ordering.bft-cert.key
rm -rf $HOME/fabric-ca/*
mkdir -p data
mkdir -p data/logs
export RUN_SUMPATH=./data/logs/ca-${ORG}.log
rm -rf /etc/hyperledger/fabric-ca-server-config/*
# Initialize the root CA
if [ ${r} -eq 1 ] ; then
	rm -rf ${FABRIC_CA_SERVER_HOME}/*
	cp -R ${DATA}/rca-${g}-home/* ${FABRIC_CA_SERVER_HOME}/
else
	rm -rf $FABRIC_CA_SERVER_HOME/*
	# Add the custom orgs
	for o in $FABRIC_ORGS; do
		aff=$aff"\n   $o: []"
	done
	logr $aff
	fabric-ca-server init -b $BOOTSTRAP_USER_PASS
	perl -0777 -i.original -pe "s/affiliations:\n   org1:\n      - department1\n      - department2\n   org2:\n      - department1/affiliations:$aff/" $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	sed -i "s/ST: \"North Carolina\"/ST: \"California\"/g" \
		$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	sed -i "s/OU: Fabric/OU: COP/g" \
		$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	sed -i "s/O: Hyperledger/O: $ORG/g" \
		$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	mkdir -p /etc/hyperledger/fabric-ca-server-config
	cp $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml /etc/hyperledger/fabric-ca-server-config/fabric-ca-server-config.yaml

	fabric-ca-server init -b $BOOTSTRAP_USER_PASS
	cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $FABRIC_CA_SERVER_TLS_KEYFILE
fi

# Start the root CA

logr "Start CA server"

fabric-ca-server start --ca.certfile $FABRIC_CA_SERVER_TLS_CERTFILE --ca.keyfile $FABRIC_CA_SERVER_TLS_KEYFILE -b $BOOTSTRAP_USER_PASS -d 2>&1 | tee -a  $RUN_SUMPATH
