#!/bin/bash
export GOPATH=/opt/gopath
export GOROOT=/opt/go
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
usage() {
	echo "Usage: $0 [-c <channel name>] [-g <orgs of peers>] [-n <chaincode name>] [-v <chaincode version>]" 1>&2
	exit 1
}
while getopts ":c:n:v:g:" o; do
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
	g)
		g=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ] || [ -z "${g}" ]; then
	usage
fi
echo "create channel channelID ${c} chaincodeName ${n} with ${v}"

source $(dirname "$0")/env.sh

PEER_ORGS=($g)
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

# install chaincode on peer0-org1, peer0-org2
for ORG in ${PEER_ORGS[*]}; do
	initPeerVars $ORG 0
	echo $ORDERER_CONN_ARGS
	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode install -n $n -v $v -p github.com/deevotech/sc-chaincode.deevo.io/transaction-fee
done

sleep 3

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode list --installed -C $CHANNEL_NAME

initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
POLICY="OR('org1MSP.member', 'org2MSP.member', 'org3MSP.member', 'org4MSP.member', 'org5MSP.member')"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode instantiate -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["init"]}' $ORDERER_CONN_ARGS
sleep 10

# test query org5
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["CreateObject","aaabbbccc","10000", "signature123", "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM", "123456"]}' $ORDERER_CONN_ARGS

# test query org4
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -c '{"Args":["ReadObject","aaabbbccc"]}' $ORDERER_CONN_ARGS
