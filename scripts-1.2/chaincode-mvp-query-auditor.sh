#!/bin/bash
usage() { echo "Usage: $0 [-c <channelname>] -n [chaincodename] -v [chaincodeversion] -g [org] -i [objectID] -t [objecttype]" 1>&2; exit 1; }
while getopts ":c:n:v:g:i:t:" o; do
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
        i)
            i=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ] || [ -z "${g}" ] || [ -z "${i}" ] || [ -z "${t}" ] ; then
    usage
fi

# init config
source $(dirname "$0")/env.sh

PEER_ORGS=("org1" "org2" "org3" "org4" "org5")
NUM_PEERS=5
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode list --installed -C $CHANNEL_NAME

# instantiate chaincode
ORG=${g}
initPeerVars ${ORG} 0
echo $ORDERER_CONN_ARGS
echo '{"Args":["getObject","'${i}'","'${t}'"]}'
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -v ${v}  -c '{"Args":["getObject","'${i}'","'${t}'"]}' $ORDERER_CONN_ARGS