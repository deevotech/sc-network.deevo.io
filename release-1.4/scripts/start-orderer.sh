#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() {
    echo "Usage: $0 [-g <orgname>] [-n <number>]" 1>&2
    exit 1
}
while getopts ":g:n:" o; do
    case "${o}" in
    g)
        g=${OPTARG}
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
if [ -z "${g}" ] || [ -z "${n}" ]; then
    usage
fi

ORG=${g}
NUMBER=${n}

source $(dirname "$0")/env.sh
initOrdererVars ${ORG} ${n}

rm -rf $ORDERER_FILELEDGER_LOCATION
mkdir -p $LOGDIR
if [ -f $LOGDIR/orderer.out ]; then
    rm $LOGDIR/orderer.out
fi
echo $ORDERER_GENERAL_LOCALMSPDIR
cp ../config/configtx.yaml ${FABRIC_CFG_PATH}/configtx.yaml
cp ../config/core.yaml ${FABRIC_CFG_PATH}/core.yaml
cp ../config/orderer.yaml ${FABRIC_CFG_PATH}/orderer.yaml

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/orderer start >$LOGDIR/orderer.out 2>&1 &
echo "done see data/logs/orderer"
