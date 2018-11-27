#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-g <org name>] [-k <cert name>] [-h <relative home directory>]" 1>&2
	exit 1
}
while getopts ":g:h:k:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	k)
		k=${OPTARG}
		;;
	h)
		h=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${h}" ] || [ -z "${k}" ]; then
	usage
fi

set -e

export RUN_SUMPATH=$ROOT_DIR/logs/client.log
export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/clients/$h
export FABRIC_CA_CLIENT_CA_NAME=localhost

if [ ! -e $ROOT_DIR/keys/$k ]; then
	logr "Please provide TLS cert for CA"
    exit 1
fi
export FABRIC_CA_CLIENT_TLS_CERTFILES=$ROOT_DIR/keys/$k

logr "Reenrolling for organization $g..."
fabric-ca-client reenroll -d 