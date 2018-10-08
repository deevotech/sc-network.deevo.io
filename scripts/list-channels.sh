#!/bin/bash
usage() { echo "Usage: $0 -g [org]" 1>&2; exit 1; }
while getopts ":g:" o; do
    case "${o}" in
        f)
            g=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ]  ; then
    usage
fi

DATA=/home/ubuntu/hyperledgerconfig/data
export FABRIC_CFG_PATH=$DATA/
CA_CHAINFILE=${DATA}/org0-ca-cert.pem
ORDERER_HOST=orderer0.org0.deevo.com
QUERY_TIMEOUT=10

ORG=${g}
PEER_HOST=peer0.${ORG}.deevo.com
PEER_NAME=${PEER_HOST}
ORG_ADMIN_HOME=$DATA/orgs/$ORG/admin
CA_CHAINFILE=${DATA}/${ORG}-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp
export CORE_PEER_ID=$PEER_HOST
export CORE_PEER_ADDRESS=$PEER_HOST:7051
export CORE_PEER_LOCALMSPID=${ORG}MSP
export CORE_LOGGING_LEVEL=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
export CORE_PEER_TLS_ROOTCERT_FILE=$CA_CHAINFILE
export CORE_PEER_TLS_CLIENTCERT_FILE=$DATA/tls/$PEER_NAME-cli-client.crt
export CORE_PEER_TLS_CLIENTKEY_FILE=$DATA/tls/$PEER_NAME-cli-client.key
export CORE_PEER_PROFILE_ENABLED=true
# gossip variables
export CORE_PEER_GOSSIP_USELEADERELECTION=true
export CORE_PEER_GOSSIP_ORGLEADER=false
export ORDERER_PORT_ARGS=" -o orderer0.org0.deevo.com:7050 --tls --cafile $DATA/org0-ca-cert.pem --clientauth"
export ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"

$GOPATH/src/github.com/hyperledger/fabric/build/bin/peer channel list $ORDERER_CONN_ARGS
