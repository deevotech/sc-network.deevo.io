#!/bin/bash
#set -e

source $(dirname "$0")/env.sh
cp ../config-1.2/configtx.yaml ${FABRIC_CFG_PATH}/
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPBFTsmart -outputBlock $GENESIS_BLOCK_FILE
if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
fi
echo "success"
