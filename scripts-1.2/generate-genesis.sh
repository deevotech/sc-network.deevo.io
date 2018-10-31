#!/bin/bash
#set -e

source $(dirname "$0")/env.sh
cp ../config-1.2/configtx.yaml ${FABRIC_CFG_PATH}/
rm $GENESIS_BLOCK_FILE
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPBFTsmart -outputBlock $GENESIS_BLOCK_FILE -channelID orderer-system-channel
if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
fi
echo "success"
