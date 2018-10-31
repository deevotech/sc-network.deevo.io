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

# init config
source $(dirname "$0")/env.sh

PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

# clone sourecode
cd $GOPATH/src/github.com/deevotech
rm -rf sc-chaincode.deevo.io
git clone https://github.com/deevotech/sc-chaincode.deevo.io

# install chaincode on peer1-org1, peer1-org2
for ORG in ${PEER_ORGS[*]}; do
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
sleep 10

JSON='{"traceable":[{"objectType":"org","id":"org_1","name":"org 1","content":"address 1","parent":""},{"objectType":"party","id":"party_1","name":"party 1","content":"","parent":"org_1"},{"objectType":"party","id":"party_2","name":"party 2","content":"","parent":"org_1"},{"objectType":"location","id":"location_1","name":"location 1","content":"","parent":"party_1"},{"objectType":"location","id":"location_2","name":"location 2","content":"","parent":"party_2"},{"objectType":"product","id":"product_1","name":"product 1","content":"","parent":"product_1"},{"objectType":"product","id":"product_2","name":"product 2","content":"","parent":"product_2"}],"auditors":[{"objectType":"auditor","id":"Auditor_1","name":"Auditor 1","content":""}]}'
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrgData", "{\"traceable\":[{\"objectType\":\"org\",\"id\":\"org_1\",\"name\":\"org 1\",\"content\":\"address 1\",\"parent\":\"\"},{\"objectType\":\"party\",\"id\":\"party_1\",\"name\":\"party 1\",\"content\":\"\",\"parent\":\"org_1\"},{\"objectType\":\"party\",\"id\":\"party_2\",\"name\":\"party 2\",\"content\":\"\",\"parent\":\"org_1\"},{\"objectType\":\"location\",\"id\":\"location_1\",\"name\":\"location 1\",\"content\":\"\",\"parent\":\"party_1\"},{\"objectType\":\"location\",\"id\":\"location_2\",\"name\":\"location 2\",\"content\":\"\",\"parent\":\"party_2\"},{\"objectType\":\"product\",\"id\":\"product_1\",\"name\":\"product 1\",\"content\":\"\",\"parent\":\"product_1\"},{\"objectType\":\"product\",\"id\":\"product_2\",\"name\":\"product 2\",\"content\":\"\",\"parent\":\"product_2\"}],\"auditors\":[{\"objectType\":\"auditor\",\"id\":\"Auditor_1\",\"name\":\"Auditor 1\",\"content\":\"\"}]}"]}' $ORDERER_CONN_ARGS
