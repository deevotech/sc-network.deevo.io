#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-g <org name>] [-b <relative bootstrap home directory>] [-a <affiliation>]" 1>&2
	exit 1
}
while getopts ":g:b:a:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	b)
		b=${OPTARG}
		;;
	a)
		a=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${b}" ] || [ -z "${a}" ]; then
	usage
fi

set -e

export RUN_SUMPATH=$ROOT_DIR/logs/client.log
export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/clients/$b
export FABRIC_CA_CLIENT_CA_NAME=localhost

if [ ! -e $ROOT_DIR/keys/tls.rca.${g}.deevo.io.pem ]; then
	log "Please provide TLS cert for CA"
    exit 1
fi
export FABRIC_CA_CLIENT_TLS_CERTFILES=$ROOT_DIR/keys/tls.rca.${g}.deevo.io.pem

fabric-ca-client affiliation add ${a}