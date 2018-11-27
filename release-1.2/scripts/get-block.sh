#!/bin/bash
usage() { echo "Usage: $0 [-c <channelname>] -n [number] -g [org] -f [fileout]" 1>&2; exit 1; }
while getopts ":c:n:g:f:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        g)
            g=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${g}" ] || [ -z "${f}" ]  ; then
    usage
fi

# init config
source $(dirname "$0")/env.sh

CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30

ORG=${g}
initPeerVars $ORG 0
echo $ORDERER_CONN_ARGS
echo "Instantiating chaincode on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer channel fetch ${n} ${f} -c $CHANNEL_NAME $ORDERER_CONN_ARGS
