#!/bin/bash
usage() {
	echo "Usage: $0 [-c <channelname>] -n [chaincodename] -v [chaincodeversion]" 1>&2
	exit 1
}
while getopts ":c:n:v:" o; do
	case "${o}" in
	c)
		c=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	v)
		v=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ]; then
	usage
fi
echo "create channel channelID ${c} chaincodeName ${n} chaincodeVersion ${v}"

# clone sourecode
cd $GOPATH/src/github.com/deevotech
rm -rf sc-chaincode.deevo.io
git clone https://github.com/deevotech/sc-chaincode.deevo.io

# init config
source $(dirname "$0")/env.sh

PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

# install chaincode on peer1-org1, peer1-org2
for ORG in $PEER_ORGS; do
	initPeerVars $ORG 1
	echo "Install for $PEER_HOST ..."
	echo $ORDERER_CONN_ARGS
	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode install -n $n -v $v -p github.com/deevotech/sc-chaincode.deevo.io/food-supplychain
done

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode list --installed -C $CHANNEL_NAME

# instantiate chaincode

initPeerVars ${PEER_ORGS[0]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode instantiate -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["init"]}' $ORDERER_CONN_ARGS
