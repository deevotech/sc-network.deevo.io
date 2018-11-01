#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() { echo "Usage: $0 [-g <orgname>]" 1>&2; exit 1; }
while getopts ":g:n:" o; do
    case "${o}" in
        g)
            g=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ] ; then
    usage
fi

source $(dirname "$0")/env.sh
initOrgVars ${g}

REPLICA_ROOT_DIR=$GOPATH/src/github.com/hyperledger/fabric-orderingservice
cp ../config-1.2/hosts.config $REPLICA_ROOT_DIR/config/hosts.config
cp ../config-1.2/node.config $REPLICA_ROOT_DIR/config/node.config
cp ../config-1.2/system.config $REPLICA_ROOT_DIR/config/system.config

cd $GOPATH/src/github.com/hyperledger/fabric-orderingservice
rm -rf config/currentView
rm -rf config/keys/*

# Copy certs
cp -a $ORG_HOME/certs/. config/keys
# Copy private key
cp $ORG_HOME/keys/cert1000.key config/keys/keystore.pem

echo $(ls config/keys)

mkdir -p /tmp/logs
./startFrontend.sh 1000 20 9999 > /tmp/logs/frontend.out 2>&1 &
echo "Success see in /tmp/logs/frontend.out"
