#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-g <org name>] [-k <cert name>] [-b <relative bootstrap home directory>] [-u <username>] [-p <password>] [-t <type>] [-r <roles>] [-a <affiliation>] [-s <attributes>]" 1>&2
	exit 1
}
while getopts ":g:b:u:p:r:t:a:k:s:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	k)
		k=${OPTARG}
		;;
	b)
		b=${OPTARG}
		;;
	u)
		u=${OPTARG}
		;;
	p)
		p=${OPTARG}
		;;
	t)
		t=${OPTARG}
		;;
	r)
		r=${OPTARG}
		;;
	a)
		a=${OPTARG}
		;;
	s)
		s=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${b}" ] || [ -z "${u}" ] || [ -z "${p}" ] || [ -z "${t}" ] || [ -z "${a}" ] || [ -z "${k}" ] || [ -z "${s}" ]; then
	usage
fi

set -e

export RUN_SUMPATH=$ROOT_DIR/logs/client.log
export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/clients/$b
export USER_PASS=${u}:${p}
export FABRIC_CA_CLIENT_CA_NAME=localhost

if [ ! -e $ROOT_DIR/keys/$k ]; then
	logr "Please provide TLS cert for CA"
    exit 1
fi
export FABRIC_CA_CLIENT_TLS_CERTFILES=$ROOT_DIR/keys/$k

if [ -e $RUN_SUMPATH ]; then
	rm $RUN_SUMPATH
fi

logr "Registering user identity ${USER_PASS}"
ROLES=""
if [ -n "${r}" ]; then
	ROLES="--id.attrs \"hf.Registrar.Roles=${r}\""
fi

fabric-ca-client register -d --id.name ${u} --id.secret ${p} --id.type ${t} --id.affiliation ${a} $ROLES --id.attrs ${s}
