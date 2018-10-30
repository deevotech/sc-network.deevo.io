#!/bin/bash
usage() { echo "Usage: $0 [-c <channelname>]" 1>&2; exit 1; }
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
shift $((OPTIND-1))
if [ -z "${c}" ] ; then
    usage
fi
echo "create channel"

DATA=/home/ubuntu/hyperledgerconfig/data
export FABRIC_CFG_PATH=$DATA/
PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

echo "Generating channel configuration transaction at $CHANNEL_TX_FILE"
$GOPATH/src/github.com/hyperledger/fabric/build/bin/configtxgen -profile SampleSingleMSPChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
echo "Failed to generate channel configuration transaction"
  fi

for ORG in ${PEER_ORGS[*]}; do
    ANCHOR_TX_FILE=$DATA/orgs/$ORG/anchors.tx
    echo  "Generating anchor peer update transaction for $ORG at $ANCHOR_TX_FILE"
 $GOPATH/src/github.com/hyperledger/fabric/build/bin/configtxgen -profile SampleSingleMSPChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE -channelID $CHANNEL_NAME -asOrg $ORG
 if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for $ORG"
 fi
done

echo "join channel to chain"
CA_CHAINFILE=${DATA}/org0-ca-cert.pem
ORDERER_HOST=orderer0.org0.deevo.com
export ORDERER_PORT_ARGS=" -o orderer0.org0.deevo.com:7050 --tls --cafile $CA_CHAINFILE --clientauth"
#initPeerVars ${PORGS[0]} 1
PEER_NAME=peer0.org1.deevo.com
PEER_HOST=$PEER_NAME
export FABRIC_CA_CLIENT=$DATA/$PEER_NAME/
export CORE_PEER_ID=peer0.org1.deevo.com
export CORE_PEER_ADDRESS=peer1-org1:7051
export CORE_PEER_LOCALMSPID=org1MSP
export CORE_LOGGING_LEVEL=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
export CORE_PEER_TLS_ROOTCERT_FILE=$DATA/org1-ca-cert.pem
export CORE_PEER_TLS_CLIENTCERT_FILE=$DATA/tls/$PEER_NAME-cli-client.crt
export CORE_PEER_TLS_CLIENTKEY_FILE=$DATA/tls/$PEER_NAME-cli-client.key
export CORE_PEER_PROFILE_ENABLED=true
   # gossip variables
export CORE_PEER_GOSSIP_USELEADERELECTION=true
export CORE_PEER_GOSSIP_ORGLEADER=false
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=$PEER_HOST:7051

export ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"
echo $ORDERER_CONN_ARGS

export CORE_PEER_MSPCONFIGPATH=$DATA/orgs/org1/admin/msp

echo "Creating channel '$CHANNEL_NAME' on $ORDERER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/build/bin/peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE $ORDERER_CONN_ARGS
