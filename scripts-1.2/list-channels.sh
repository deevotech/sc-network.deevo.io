#!/bin/bash
usage() { echo "Usage: $0 -g [org] -n [Peer Num] -l [log level]" 1>&2; exit 1; }
while getopts ":g:l:n:" o; do
    case "${o}" in
        g)
            g=${OPTARG}
            ;;
        l)
            l=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ] || [ -z "${l}" ] || [ -z "${n}" ] ; then
    usage
fi

ORG=${g}
source $(dirname "$0")/env.sh
initPeerVars ${ORG} ${n}

QUERY_TIMEOUT=10

$GOPATH/src/github.com/hyperledger/fabric/build/bin/peer channel list $ORDERER_CONN_ARGS --logging-level $l
