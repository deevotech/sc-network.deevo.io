#!/bin/bash
export GOPATH=/opt/gopath
export GOROOT=/opt/go
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
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
echo "create channel channelID ${c} chaincodeName ${n} with ${v}"

source $(dirname "$0")/env.sh

PEER_ORGS="org1 org2 org3 org4 org5"
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

# install chaincode on peer1-org1, peer1-org2
for ORG in $PEER_ORGS; do
	initPeerVars $ORG 1
	echo $ORDERER_CONN_ARGS
	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode install -n $n -v $v -p github.com/hyperledger/caliper/src/contract/fabric/simple/go
done

sleep 3

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode list --installed -C $CHANNEL_NAME

initPeerVars ${PEER_ORGS[1]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
POLICY="OR('org1MSP.member', 'org2MSP.member', 'org3MSP.member', 'org4MSP.member', 'org5MSP.member')"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode instantiate -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["init"]}' $ORDERER_CONN_ARGS
sleep 10

# test query org5
initPeerVars ${PEER_ORGS[5]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["open","aaabbbccc","10000"]}' $ORDERER_CONN_ARGS

# test query org5
initPeerVars ${PEER_ORGS[4]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["open","aaabbbddd","10000"]}' $ORDERER_CONN_ARGS

# test query org3
initPeerVars ${PEER_ORGS[3]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["open","aaabbbeee","10000"]}' $ORDERER_CONN_ARGS

# test query org2
initPeerVars ${PEER_ORGS[2]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -v ${v} -c '{"Args":["open","aaabbbfff","10000"]}' $ORDERER_CONN_ARGS
echo "done"
