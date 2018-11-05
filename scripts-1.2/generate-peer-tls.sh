#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source $(dirname "$0")/env.sh

usage() { echo "Usage: $0 [-g <orgname>] [-n <numberpeer>]" 1>&2; exit 1; }
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

function enrollCAAdmin() {
	mkdir -p $FABRIC_CA_CLIENT_HOME
	rm -rf $FABRIC_CA_CLIENT_HOME/*
	
	logr "Enrolling with $ENROLLMENT_URL as bootstrap identity ..."
	fabric-ca-client enroll -d -u $ENROLLMENT_URL --enrollment.profile tls
}

# Register any identities associated with a peer
function registerPeerIdentities() {
	enrollCAAdmin

	fabric-ca-client register -d --id.name $PEER_NAME --id.secret $PEER_PASS --id.type peer --id.affiliation $ORG --id.attrs 'admin=true:ecert'
	# fabric-ca-client register -d --id.name $PEER_NAME --id.secret $PEER_PASS --id.type peer --id.affiliation $ORG

	logr "Registering admin identity with $ADMIN_NAME:$ADMIN_PASS"
	# The admin identity has the "admin" attribute which is added to ECert by default
	fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.affiliation $ORG --id.attrs '"hf.Registrar.Roles=user"' --id.attrs '"hf.Registrar.Attributes=*"' --id.attrs 'hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,mycc.init=true:ecert'
	logr "Registering user identity with $USER_NAME:$USER_PASS"
	fabric-ca-client register -d --id.name $USER_NAME --id.secret $USER_PASS --id.affiliation $ORG --id.attrs '"hf.Registrar.Roles=user"'
}

function getCACerts() {
	logr "Getting CA certificates ..."
	logr "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
	mkdir -p $ORG_MSP_DIR
	fabric-ca-client getcacert -d -u $ENROLLMENT_URL -M $ORG_MSP_DIR --enrollment.profile tls
	cp $ROOT_CA_CERTFILE $ORG_MSP_DIR/cacerts

	# Copy CA cert
	cp $ROOT_CA_CERTFILE $FABRIC_CA_CLIENT_HOME/msp/cacerts
}

function main() {
	registerPeerIdentities
	getCACerts
	logr "Finished create certificates"
	logr "Start create TLS"

	mkdir -p $PEER_CERT_DIR
	logr "Generate server TLS cert and key pair for the peer"
	genMSPCerts $CORE_PEER_ID $CORE_PEER_ID $PEER_PASS $ORG $CA_HOST $PEER_CERT_DIR/msp
	cp $ROOT_CA_CERTFILE $PEER_CERT_DIR/msp/cacerts

	mkdir -p $PEER_CERT_DIR/tls
	cp $PEER_CERT_DIR/msp/signcerts/* $PEER_CERT_DIR/tls/server.crt
	cp $PEER_CERT_DIR/msp/keystore/* $PEER_CERT_DIR/tls/server.key

	logr "Generate client TLS cert and key pair for the user client"
	genMSPCerts $CORE_PEER_ID $USER_NAME $USER_PASS $ORG $CA_HOST $USER_CERT_DIR/msp
	cp $ROOT_CA_CERTFILE $USER_CERT_DIR/msp/cacerts

    mkdir -p $USER_CERT_DIR/tls
	cp $USER_CERT_DIR/msp/signcerts/* $USER_CERT_DIR/tls/client.crt
	cp $USER_CERT_DIR/msp/keystore/* $USER_CERT_DIR/tls/client.key

	if [ $n -eq 1 ]; then
		logr "Generate client TLS cert and key pair for the peer CLI"
		genMSPCerts $CORE_PEER_ID $ADMIN_NAME $ADMIN_PASS $ORG $CA_HOST $ADMIN_CERT_DIR/msp
		cp $ROOT_CA_CERTFILE $ADMIN_CERT_DIR/msp/cacerts

        mkdir -p $ADMIN_CERT_DIR/tls
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ADMIN_CERT_DIR/tls/server.crt
		cp $ADMIN_CERT_DIR/msp/keystore/* $ADMIN_CERT_DIR/tls/server.key
		mkdir -p $ADMIN_CERT_DIR/msp/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ADMIN_CERT_DIR/msp/admincerts/cert.pem
		logr "Copy the org's admin cert into some target MSP directory"

		mkdir -p $PEER_CERT_DIR/msp/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $PEER_CERT_DIR/msp/admincerts/admin-user.pem
		cp $PEER_CERT_DIR/msp/signcerts/* $PEER_CERT_DIR/msp/admincerts/admin-peer.pem

		mkdir -p $USER_CERT_DIR/msp/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $USER_CERT_DIR/msp/admincerts/admin-user.pem
		cp $PEER_CERT_DIR/msp/signcerts/* $USER_CERT_DIR/msp/admincerts/admin-peer.pem

		mkdir -p $ORG_MSP_DIR/admincerts
		cp $ADMIN_CERT_DIR/msp/signcerts/* $ORG_MSP_DIR/admincerts/admin-user.pem
		cp $PEER_CERT_DIR/msp/signcerts/* $ORG_MSP_DIR/admincerts/admin-peer.pem
	fi

	logr "Finished create TLS"
}

export RUN_SUMPATH=data/logs/peer${g}-${n}.log
mkdir -p data/logs
ORG=${g}
initPeerVars $ORG ${n}
mkdir -p ${ORG_HOME}

main