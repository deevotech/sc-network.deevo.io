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
# test query org1
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
# Address: "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j",
# Publickey: `
# -----BEGIN PUBLIC KEY-----
# MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUkaGIAmlbgE9lfFz2wdMlZSMyTyh
# KnVw7s2wQEgkCA7yrKr8iEXxtGflsBLtqLH7LE071/G3lXn0+tjhlv1Uww==
# -----END PUBLIC KEY-----
#`,
# Balance: 1000,
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initAcc","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j","-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUkaGIAmlbgE9lfFz2wdMlZSMyTyh\nKnVw7s2wQEgkCA7yrKr8iEXxtGflsBLtqLH7LE071/G3lXn0+tjhlv1Uww==\n-----END PUBLIC KEY-----", "1000"]}' $ORDERER_CONN_ARGS
# test query org5
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["getBalance","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j"]}' $ORDERER_CONN_ARGS