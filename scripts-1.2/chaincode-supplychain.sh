#!/bin/bash
usage() {
	echo "Usage: $0 [-c <channelname>] -n [chaincodename]" 1>&2
	exit 1
}
while getopts ":c:n:" o; do
	case "${o}" in
	c)
		c=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${c}" ] || [ -z "${n}" ]; then
	usage
fi
echo "create channel channelID ${c} chaincodeName ${n} "

source $(dirname "$0")/env.sh

PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

# install chaincode on peer1-org1, peer1-org2
for ORG in ${PEER_ORGS[*]}; do
	initPeerVars $ORG 1
	echo "Install for $PEER_HOST ..."
	echo $ORDERER_CONN_ARGS
	$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode install -n $n -v 1.0 -p github.com/deevotech/sc-chaincode.deevo.io/supplychain/go
	#$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode install -n ${n} -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
	#sleep 3
done

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode list --installed -C $CHANNEL_NAME

initPeerVars ${PORGS[1]} 1
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode instantiate -C $CHANNEL_NAME -n ${n} -v 1.0 -c '{"Args":["init"]}' $ORDERER_CONN_ARGS

sleep 10
echo "Updating anchor peers for $PEER_HOST ..."

echo "Sending invoke transaction to $PEER_HOST ..."
echo "init orgs"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","1","supplier1","1","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
sleep 3
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","2","supplier2","1", "67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
sleep 3
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","3","farmer1","2","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","4","farmer2","2","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","5","factory1","3","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","6","factory2","3","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","7","retailer1","4","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","8","retailer3","4","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","9","consumer1","5","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","10","consumer2","5","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
#$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","11","tree1","6","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
#$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initOrg","12","tree2","6","67.0006, -70.5476"]}' $ORDERER_CONN_ARGS
echo "init trees for farmer1 and farmer2"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initFarmerTree","11","tree1","1000","11", "12", "1", "3", "1000"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initFarmerTree","12","tree2","1000","13", "14", "3", "4", "1000"]}' $ORDERER_CONN_ARGS
echo "init suppliermaterials"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","1","material1","10","1"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","2","material2","20","1"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","3","material3","15","2"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","4","material4","30","2"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","2","material5","30","1"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initSupplierMaterial","3","material6","30","2"]}' $ORDERER_CONN_ARGS
sleep 3
echo "action sell material1 to farmer1"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material1","3"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material2","3"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material3","4"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material4","4"]}' $ORDERER_CONN_ARGS
sleep 3 "action material to tree"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material1","11"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material2","11"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material3","12"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerMaterial","material4","12"]}' $ORDERER_CONN_ARGS
sleep 3
echo "action get historyfor Materials 1, 2, 3, 4"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForMaterial","material1"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForMaterial","material2"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForMaterial","material3"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForMaterial","material4"]}' $ORDERER_CONN_ARGS
sleep 3
#Rich Query (Only supported if CouchDB is used as state database):
echo "query Materials By Owner"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["queryMaterialsByOwner","3"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["queryMaterialsByOwner","4"]}' $ORDERER_CONN_ARGS
sleep 3
echo "action harvest agri product"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["harvestAgriProduct","111", "aproduct1", "11", "1000", "3"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["harvestAgriProduct","112", "aproduct1", "12", "2000", "4"]}' $ORDERER_CONN_ARGS
echo "action sell agri product for factory 1 and factory 2"
sleep 3
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerAgriProduct","aproduct1", "5"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerAgriProduct","aproduct2", "6"]}' $ORDERER_CONN_ARGS
echo "action make product from agri product"
sleep 3
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["makeProduct","111", "221", "product1", "10000", "5"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["makeProduct","112", "222", "product2", "20000", "6"]}' $ORDERER_CONN_ARGS
echo "action change to retailer"
sleep 3
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerProduct","product1", "7"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerProduct","product2", "8"]}' $ORDERER_CONN_ARGS
sleep 3
echo "action sell to customer 1 and customer 2"

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerProduct","product1", "9"]}' $ORDERER_CONN_ARGS
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["changeOwnerProduct","product2", "10"]}' $ORDERER_CONN_ARGS
sleep 3
echo "get history of product1"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForProduct","product1"]}' $ORDERER_CONN_ARGS
echo "get history of product2"
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getHistoryForProduct","product2"]}' $ORDERER_CONN_ARGS
echo "done test"
