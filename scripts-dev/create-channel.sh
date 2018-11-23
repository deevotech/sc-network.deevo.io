#!/bin/bash
export FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/
export CHANNEL_NAME=testchannel
CHANNEL_TX_FILE=$FABRIC_CFG_PATH/$CHANNEL_NAME.tx
ANCHOR_TX_FILE=$FABRIC_CFG_PATH/anchors.tx

if [ -f $CHANNEL_TX_FILE ]; then
	rm $CHANNEL_TX_FILE
fi

echo "Generating channel configuration transaction at $CHANNEL_TX_FILE"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
	echo "Failed to generate channel configuration transaction"
fi

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE -channelID $CHANNEL_NAME -asOrg SampleOrg

echo "join channel to chain"

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE -o 127.0.0.1:7050

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel join -b $CHANNEL_NAME.block


export CORE_PEER_ADDRESS=127.0.0.1:7051
export CORE_PEER_LOCALMSPID=SampleOrg
export CORE_LOGGING_LEVEL=DEBUG
export CORE_PEER_TLS_ENABLED=false
export CORE_PEER_TLS_CLIENTAUTHREQUIRED=false
export CORE_PEER_PROFILE_ENABLED=true
# gossip variables
export CORE_PEER_GOSSIP_USELEADERELECTION=true
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel update -c $CHANNEL_NAME -f $ANCHOR_TX_FILE -o 127.0.0.1:7050
