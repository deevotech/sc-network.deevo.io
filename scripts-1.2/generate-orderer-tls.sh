#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
set -e

source $(dirname "$0")/env.sh

# Wait for setup to complete sucessfully
usage() { echo "Usage: $0 [-g <orgname>] [-n <numberorderer>]" 1>&2; exit 1; }
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
shift $((OPTIND-1))
if [ -z "${g}" ] || [ -z "${n}" ] ; then
    usage
fi

ORG=${g}
mkdir -p ${DATA}
mkdir -p data/logs
export RUN_SUMPATH=data/logs/orderer${n}-${g}.log

initOrdererVars $ORG ${n}

function enrollCAAdmin() {
	mkdir -p FABRIC_CA_CLIENT_HOME
	rm -rf FABRIC_CA_CLIENT_HOME/*
	
	logr "Enrolling with $ENROLLMENT_URL as bootstrap identity ..."
	fabric-ca-client enroll -d -u $ENROLLMENT_URL --enrollment.profile tls
}

# Register any identities associated with a peer
function registerOrdererIdentities() {
	enrollCAAdmin

	fabric-ca-client register -d --id.name $ORDERER_NAME --id.secret $ORDERER_PASS --id.type orderer --id.affiliation $ORG

	logr "Registering admin identity with $ADMIN_NAME:$ADMIN_PASS"
	# The admin identity has the "admin" attribute which is added to ECert by default
	fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "admin=true:ecert" --id.affiliation $ORG
}

function getCACerts() {
	logr "Getting CA certificates ..."
	logr "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
	mkdir -p $ORG_MSP_DIR
	fabric-ca-client getcacert -d -u $ENROLLMENT_URL -M $ORG_MSP_DIR
	mkdir -p $ORG_MSP_DIR/tlscacerts
	cp $ROOT_TLS_CERTFILE $ORG_MSP_DIR/tlscacerts

	# Copy CA cert
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
	cp $ROOT_TLS_CERTFILE  $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
}

function main() {
	registerOrdererIdentities
	getCACerts
	logr "Finished create certificates"
	logr "Start create TLS"

	logr "Enroll again to get the orderer's enrollment certificate (default profile)"
	genMSPCerts $ORDERER_HOST $ORDERER_NAME $ORDERER_PASS $ORG $CA_HOST $ORDERER_CERT_DIR/msp

	mkdir -p $ORDERER_CERT_DIR/tls
	cp $ORDERER_CERT_DIR/msp/signcerts/* $ORDERER_CERT_DIR/tls/server.crt
	cp $ORDERER_CERT_DIR/msp/keystore/* $ORDERER_CERT_DIR/tls/server.key

	if [ $ADMINCERTS ]; then
		logr "Generate client TLS cert and key pair for the peer CLI"
		genMSPCerts $ORDERER_HOST $ADMIN_NAME $ADMIN_PASS $ORG $CA_HOST $ADMIN_CERT_DIR/msp

        mkdir -p $ADMIN_CERT_DIR/tls
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ADMIN_CERT_DIR/tls/client.crt
		cp $ADMIN_CERT_DIR/msp/keystore/* $ADMIN_CERT_DIR/tls/client.key

		mkdir -p $ADMIN_CERT_DIR/msp/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ADMIN_CERT_DIR/msp/admincerts/cert.pem
		logr "Copy the org's admin cert into some target MSP directory"

		mkdir -p $ORDERER_CERT_DIR/msp/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ORDERER_CERT_DIR/msp/admincerts/cert.pem

		mkdir -p $ORG_MSP_DIR/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ORG_MSP_DIR/admincerts/admin-cert.pem
		cp $ORDERER_CERT_DIR/msp/signcerts/* $ORG_MSP_DIR/admincerts/orderer-cert.pem
	fi

	logr "Finished create TLS"
}

main