#!/bin/bash
usage() {
	echo "Usage: $0 [-c <channelname>]" 1>&2
	exit 1
}
while getopts ":c:" o; do
	case "${o}" in
	c)
		c=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${c}" ]; then
	usage
fi
echo "create channel"

source $(dirname "$0")/env.sh

PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

echo "Generating channel configuration transaction at $CHANNEL_TX_FILE"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
	echo "Failed to generate channel configuration transaction"
fi

for ORG in ${PEER_ORGS[*]}; do
	ANCHOR_TX_FILE=$DATA/orgs/$ORG/anchors.tx
	echo "Generating anchor peer update transaction for $ORG at $ANCHOR_TX_FILE"
	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/configtxgen -profile SampleSingleMSPChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE -channelID $CHANNEL_NAME -asOrg $ORG
	if [ "$?" -ne 0 ]; then
		echo "Failed to generate anchor peer update for $ORG"
	fi
done

echo "join channel to chain"
initPeerVars ${PEER_ORGS[0]} 1

echo "Creating channel '$CHANNEL_NAME' on $ORDERER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE $ORDERER_CONN_ARGS

sleep 10
# All peers join the channel
echo "ALL peers join the channel"
for ORG in ${PEER_ORGS[*]}; do
    initPeerVars ${ORG} 1

	C=1
	MAX_RETRY=10
	while true; do
		echo "Peer $PEER_HOST is attempting to join channel '$CHANNEL_NAME' (attempt #${C}) ..."
		$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel join -b $CHANNEL_NAME.block
		if [ $? -eq 0 ]; then
			echo "Peer $PEER_HOST successfully joined channel '$CHANNEL_NAME'"
			break
		fi
		if [ $C -gt $MAX_RETRY ]; then
			echo "Peer $PEER_HOST failed to join channel '$CHANNEL_NAME' in $MAX_RETRY retries"
		fi
		C=$((C + 1))
		sleep 2
	done
	#done
done

sleep 5
# Update the anchor peers
for ORG in ${PEER_ORGS[*]}; do
	initPeerVars $ORG 1

	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel update -c $CHANNEL_NAME -f $ANCHOR_TX_FILE $ORDERER_CONN_ARGS
	sleep 2
done
