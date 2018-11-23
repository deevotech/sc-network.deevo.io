#!/bin/bash
#set -e
export FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/
export GENESIS_BLOCK_FILE=${FABRIC_CFG_PATH}/genesis.block
if [ -f $GENESIS_BLOCK_FILE ]; then
	rm $GENESIS_BLOCK_FILE
fi

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPDeevoconsensus -outputBlock $GENESIS_BLOCK_FILE -channelID testchainid
if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
fi
echo "success"
