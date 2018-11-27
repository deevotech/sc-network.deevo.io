#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

ROOT_DIR=$HOME/fabric-ca

# Switch to the current org's admin identity.  Enroll if not previously enrolled.
# function switchToAdminIdentity() {
# 	if [ ! -d $ORG_ADMIN_HOME ]; then
# 		#dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
# 		log "Enrolling admin '$ADMIN_NAME' with $CA_HOST ..."
# 		export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
# 		export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
# 		$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client enroll -d -u https://$ADMIN_NAME:$ADMIN_PASS@$CA_HOST:7054
# 		# If admincerts are required in the MSP, copy the cert there now and to my local MSP also
# 		if [ $ADMINCERTS ]; then
# 			mkdir -p $(dirname "${ORG_ADMIN_CERT}")
# 			cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
# 			mkdir $ORG_ADMIN_HOME/msp/admincerts
# 			cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
# 		fi
# 	fi
# 	export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp
# }

# Switch to the current org's user identity.  Enroll if not previously enrolled.
# function switchToUserIdentity() {
# 	export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric/orgs/$ORG/user
# 	export CORE_PEER_MSPCONFIGPATH=$FABRIC_CA_CLIENT_HOME/msp
# 	if [ ! -d $FABRIC_CA_CLIENT_HOME ]; then
# 		#dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
# 		log "Enrolling user for organization $ORG with home directory $FABRIC_CA_CLIENT_HOME ..."
# 		export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
# 		fabric-ca-client enroll -d -u https://$USER_NAME:$USER_PASS@$CA_HOST:7054
# 		# Set up admincerts directory if required
# 		if [ $ADMINCERTS ]; then
# 			ACDIR=$CORE_PEER_MSPCONFIGPATH/admincerts
# 			mkdir -p $ACDIR
# 			cp $ORG_ADMIN_HOME/msp/signcerts/* $ACDIR
# 		fi
# 	fi
# }

# Revokes the fabric user
# function revokeFabricUserAndGenerateCRL() {
# 	switchToAdminIdentity
# 	export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
# 	logr "Revoking the user '$USER_NAME' of the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME and generating CRL ..."
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
# 	$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client revoke -d --revoke.name $USER_NAME --gencrl
# }

# Generates a CRL that contains serial numbers of all revoked enrollment certificates.
# The generated CRL is placed in the crls folder of the admin's MSP
# function generateCRL() {
# 	switchToAdminIdentity
# 	export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
# 	logr "Generating CRL for the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME ..."
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
# 	$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client gencrl -d
# }

# log a message
function log() {
	if [ "$1" = "-n" ]; then
		shift
		echo -ne "\e[91m##### $(date '+%Y-%m-%d %H:%M:%S') ##### $*\e[0m"
	else
		echo -e "\e[91m##### $(date '+%Y-%m-%d %H:%M:%S') ##### $*\e[0m"
	fi
}

# fatal a message
function fatal() {
	log "FATAL: $*"
	exit 1
}

function genMSPCerts() {
	if [ $# -ne 6 ]; then
		echo "Usage: genMSPCerts <host name> <name> <password> <org> <ca host> <msp dir>: $*"
		exit 1
	fi

	HOST_NAME=$1
	NAME=$2
	PASSWORD=$3
	ORG=$4
	CA_HOST_NAME=$5
	MSP_DIR=$6

	logr "Enroll to get peer's TLS cert"

	mkdir -p $MSP_DIR
	rm -rf $MSP_DIR/*
	echo $HOST_NAME
	echo $NAME
	echo $PASSWORD
	echo $CA_HOST_NAME
	echo $MSP_DIR
	echo $ORG

	#fabric-ca-client enroll -d --enrollment.profile tls -u https://$NAME:$PASSWORD@$CA_HOST_NAME:7054 -M $MSP_DIR --csr.hosts $HOST_NAME --csr.names C=US,ST=California,O=${ORG},OU=COP
	fabric-ca-client enroll -d --enrollment.profile tls -u https://$NAME:$PASSWORD@$CA_HOST_NAME:7054 -M $MSP_DIR --csr.hosts $HOST_NAME
}

function logr() {
	log $*
	log $* >>$RUN_SUMPATH
}
