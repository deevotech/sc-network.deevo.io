#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-g <org name>] [-k <cert name>] [-h <relative home directory>] [-u <user and password>]" 1>&2
	exit 1
}
while getopts ":g:h:u:k:" o; do
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
	u)
		u=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${h}" ] || [ -z "${u}" ] || [ -z "${k}" ]; then
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

if [ -e $RUN_SUMPATH ]; then
	rm $RUN_SUMPATH
fi
if [ ! -d $FABRIC_CA_CLIENT_HOME ]; then
	mkdir -p $FABRIC_CA_CLIENT_HOME
else
	rm -rf $FABRIC_CA_CLIENT_HOME/*
fi

logr "Enrolling for organization $g with ${u}@localhost:7054 ..."
fabric-ca-client enroll -d -u https://${u}@localhost:7054