#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#
# The following variables describe the topology and may be modified to provide
# different organization names or the number of peers in each peer organization.
#

# Name of the docker-compose network
NETWORK=supply-chain-network

# Names of the orderer organizations
ORDERER_ORGS="org0"

# Names of the peer organizations
PEER_ORGS="org1 org2 org3 org4 org5"

# Number of peers in each peer organization
NUM_PEERS=5

#
# The remainder of this file contains variables which typically would not be changed.
#

# All org names
ORGS="$ORDERER_ORGS $PEER_ORGS"

# Set to true to populate the "admincerts" folder of MSPs
ADMINCERTS=true

# Number of orderer nodes
NUM_ORDERERS=1

# The volume mount to share data between containers
DATA=$HOME/hyperledgerconfig/data
export FABRIC_CFG_PATH=$DATA

# The path to the genesis block
GENESIS_BLOCK_FILE=$DATA/genesis.block

# Name of test channel
CHANNEL_NAME=mychannel

# The path to a channel transaction
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

# Query timeout in seconds
QUERY_TIMEOUT=15

# Setup timeout in seconds (for setup container to complete)
SETUP_TIMEOUT=120

# Log directory
LOGDIR=$DATA/logs
LOGPATH=$LOGDIR

# Name of a the file to create when setup is successful
SETUP_SUCCESS_FILE=${LOGDIR}/setup.successful
# The setup container's log file
SETUP_LOGFILE=${LOGDIR}/setup.log

# The run container's log file
RUN_LOGFILE=${LOGDIR}/run.log
# The run container's summary log file
RUN_SUMFILE=${LOGDIR}/run.sum
RUN_SUMPATH=${RUN_SUMFILE}
# Run success and failure files
RUN_SUCCESS_FILE=${LOGDIR}/run.success
RUN_FAIL_FILE=${LOGDIR}/run.fail

# initOrgVars <ORG>
function initOrgVars() {
	if [ $# -ne 1 ]; then
		echo "Usage: initOrgVars <ORG>"
		exit 1
	fi
	ORG=$1
	ROOT_CA_HOST=rca.${ORG}.deevo.io
	ROOT_CA_NAME=rca.${ORG}.deevo.io

	# Admin identity for the org
	ADMIN_NAME=admin-${ORG}
	ADMIN_PASS=${ADMIN_NAME}pw
	# Typical user identity for the org
	USER_NAME=user-${ORG}
	USER_PASS=${USER_NAME}pw

	# Root CA admin identity
	ROOT_CA_ADMIN_USER_PASS=rca-admin:rca-adminpw

	ROOT_CA_CERTFILE=$DATA/ca/rca.${ORG}.deevo.io.pem

	ORG_HOME=$DATA/orgs/${ORG}
	mkdir -p $ORG_HOME

	ANCHOR_TX_FILE=$ORG_HOME/anchors.tx
	ORG_MSP_ID=${ORG}MSP
	ORG_MSP_DIR=$ORG_HOME/msp
	ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/cert.pem
	# ORG_ADMIN_HOME=${DATA}/orgs/$ORG/admin

	export CA_NAME=$ROOT_CA_NAME
	export CA_HOST=$ROOT_CA_HOST
	export CA_CHAINFILE=$ROOT_CA_CERTFILE
	export CA_ADMIN_USER_PASS=$ROOT_CA_ADMIN_USER_PASS
	export ENROLLMENT_URL=https://rca-${ORG}-admin:rca-${ORG}-adminpw@rca.${ORG}.deevo.io:7054

	export USER_CERT_DIR=$ORG_HOME/user
	export ADMIN_CERT_DIR=$ORG_HOME/admin
}

# initPeerVars <ORG> <NUM>
function initPeerVars() {
	if [ $# -ne 2 ]; then
		echo "Usage: initPeerVars <ORG> <NUM>: $*"
		exit 1
	fi
	ORG=$1
	NUM=$2

	initOrgVars $1
	export PEER_HOST=peer${NUM}.${ORG}.deevo.io
	export PEER_NAME=peer${NUM}.${ORG}.deevo.io
	export PEER_PASS=${PEER_NAME}pw

	export PEER_CERT_DIR=$ORG_HOME/$PEER_NAME
	export FABRIC_CA_CLIENT_HOME=$DATA/ca-client

	export CORE_PEER_ID=$PEER_HOST
	export CORE_PEER_ADDRESS=$PEER_HOST:7051
	export CORE_PEER_LOCALMSPID=$ORG_MSP_ID
	export CORE_PEER_MSPCONFIGPATH=$ORG_MSP_DIR
	export CORE_LOGGING_LEVEL=debug
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
	export CORE_PEER_TLS_ROOTCERT_FILE=$CA_CHAINFILE
	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
	export CORE_PEER_TLS_CLIENTROOTCAS_FILES=$CA_CHAINFILE
	export PEER_GOSSIP_SKIPHANDSHAKE=true

	PEER_TLS_DIR=$PEER_CERT_DIR/tls
	export CORE_PEER_TLS_KEY_FILE=$PEER_TLS_DIR/server.key
	export CORE_PEER_TLS_CERT_FILE=$PEER_TLS_DIR/server.crt

	ADMIN_TLS_DIR=$ADMIN_CERT_DIR/tls
	export CORE_PEER_TLS_CLIENTCERT_FILE=$ADMIN_TLS_DIR/server.crt
	export CORE_PEER_TLS_CLIENTKEY_FILE=$ADMIN_TLS_DIR/server.key

	export CORE_PEER_PROFILE_ENABLED=true
	# gossip variables
	export CORE_PEER_GOSSIP_USELEADERELECTION=true
	export CORE_PEER_GOSSIP_ORGLEADER=false
	export CORE_PEER_GOSSIP_EXTERNALENDPOINT=$PEER_HOST:7051
	if [ $NUM -gt 1 ]; then
		# Point the non-anchor peers to the anchor peer, which is always the 1st peer
		export CORE_PEER_GOSSIP_BOOTSTRAP=peer1.${ORG}.deevo.io:7051
		export CORE_PEER_ADDRESSAUTODETECT=true
	fi

	export ORDERER_ORG=org0
	export ORDERER_HOST=orderer1.${ORDERER_ORG}.deevo.io
	export ORDERER_TLS_CA=$DATA/ca/rca.${ORDERER_ORG}.deevo.io.pem
	export ORDERER_PORT_ARGS="-o $ORDERER_HOST:7050 --tls --cafile $ORDERER_TLS_CA --clientauth"

	export ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"
}

# initOrdererVars <NUM>
function initOrdererVars() {
	if [ $# -ne 2 ]; then
		echo "Usage: initOrdererVars <ORG> <NUM>"
		exit 1
	fi
	initOrgVars $1
	NUM=$2
	export ORDERER_HOST=orderer${NUM}.${ORG}.deevo.io
	export ORDERER_NAME=orderer${NUM}.${ORG}.deevo.io
	export ORDERER_PASS=${ORDERER_NAME}pw
	export ORDERER_NAME_PASS=${ORDERER_NAME}:${ORDERER_PASS}

	export ORDERER_CERT_DIR=$ORG_HOME/$ORDERER_NAME

	export FABRIC_CA_CLIENT_HOME=$DATA/ca-client
	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
	export ORDERER_GENERAL_LOGLEVEL=debug
	export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
	export ORDERER_GENERAL_GENESISMETHOD=file
	export ORDERER_GENERAL_GENESISFILE=$GENESIS_BLOCK_FILE
	export ORDERER_GENERAL_LOCALMSPID=$ORG_MSP_ID
	export ORDERER_GENERAL_LOCALMSPDIR=$ORG_MSP_DIR
	# enabled TLS
	export ORDERER_GENERAL_TLS_ENABLED=true
	export TLSDIR=$ORDERER_CERT_DIR/tls
	export ORDERER_GENERAL_TLS_PRIVATEKEY=$TLSDIR/server.key
	export ORDERER_GENERAL_TLS_CERTIFICATE=$TLSDIR/server.crt
	export ORDERER_GENERAL_TLS_ROOTCAS=[$CA_CHAINFILE]
	export ORDERER_GENERAL_TLS_CLIENTROOTCAS=[$CA_CHAINFILE]
	export ORDERER_HOME=${DATA}/orderer
	export ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED=true
	export ORDERER_FILELEDGER_LOCATION=/var/hyperledger/production/orderer
}

# Switch to the current org's admin identity.  Enroll if not previously enrolled.
function switchToAdminIdentity() {
	if [ ! -d $ORG_ADMIN_HOME ]; then
		#dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
		log "Enrolling admin '$ADMIN_NAME' with $CA_HOST ..."
		export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
		export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
		$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client enroll -d -u https://$ADMIN_NAME:$ADMIN_PASS@$CA_HOST:7054
		# If admincerts are required in the MSP, copy the cert there now and to my local MSP also
		if [ $ADMINCERTS ]; then
			mkdir -p $(dirname "${ORG_ADMIN_CERT}")
			cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
			mkdir $ORG_ADMIN_HOME/msp/admincerts
			cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
		fi
	fi
	export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp
}

# Switch to the current org's user identity.  Enroll if not previously enrolled.
function switchToUserIdentity() {
	export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric/orgs/$ORG/user
	export CORE_PEER_MSPCONFIGPATH=$FABRIC_CA_CLIENT_HOME/msp
	if [ ! -d $FABRIC_CA_CLIENT_HOME ]; then
		#dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
		log "Enrolling user for organization $ORG with home directory $FABRIC_CA_CLIENT_HOME ..."
		export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
		fabric-ca-client enroll -d -u https://$USER_NAME:$USER_PASS@$CA_HOST:7054
		# Set up admincerts directory if required
		if [ $ADMINCERTS ]; then
			ACDIR=$CORE_PEER_MSPCONFIGPATH/admincerts
			mkdir -p $ACDIR
			cp $ORG_ADMIN_HOME/msp/signcerts/* $ACDIR
		fi
	fi
}

# Revokes the fabric user
function revokeFabricUserAndGenerateCRL() {
	switchToAdminIdentity
	export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
	logr "Revoking the user '$USER_NAME' of the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME and generating CRL ..."
	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
	$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client revoke -d --revoke.name $USER_NAME --gencrl
}

# Generates a CRL that contains serial numbers of all revoked enrollment certificates.
# The generated CRL is placed in the crls folder of the admin's MSP
function generateCRL() {
	switchToAdminIdentity
	export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
	logr "Generating CRL for the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME ..."
	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
	$GOPATH/src/github.com/hyperledger/fabric-ca/cmd/fabric-ca-client/fabric-ca-client gencrl -d
}

function awaitSetup() {
	dowait "the 'setup' container to finish registering identities, creating the genesis block and other artifacts" $SETUP_TIMEOUT $SETUP_LOGFILE /$SETUP_SUCCESS_FILE
}

# Wait for one or more files to exist
# Usage: dowait <what> <timeoutInSecs> <errorLogFile> <file> [<file> ...]
function dowait() {
	if [ $# -lt 4 ]; then
		fatal "Usage: dowait: $*"
	fi
	local what=$1
	local secs=$2
	local logFile=$3
	shift 3
	local logit=true
	local starttime=$(date +%s)
	for file in $*; do
		until [ -f $file ]; do
			if [ "$logit" = true ]; then
				log -n "Waiting for $what ..."
				logit=false
			fi
			sleep 1
			if [ "$(($(date +%s) - starttime))" -gt "$secs" ]; then
				echo ""
				fatal "Failed waiting for $what ($file not found); see $logFile"
			fi
			echo -n "."
		done
	done
	echo ""
}

# Wait for a process to begin to listen on a particular host and port
# Usage: waitPort <what> <timeoutInSecs> <errorLogFile> <host> <port>
function waitPort() {
	set +e
	local what=$1
	local secs=$2
	local logFile=$3
	local host=$4
	local port=$5
	nc -z $host $port >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log -n "Waiting for $what ..."
		local starttime=$(date +%s)
		while true; do
			sleep 1
			nc -z $host $port >/dev/null 2>&1
			if [ $? -eq 0 ]; then
				break
			fi
			if [ "$(($(date +%s) - starttime))" -gt "$secs" ]; then
				fatal "Failed waiting for $what; see $logFile"
			fi
			echo -n "."
		done
		echo ""
	fi
	set -e
}

# log a message
function log() {
	if [ "$1" = "-n" ]; then
		shift
		echo -n "##### $(date '+%Y-%m-%d %H:%M:%S') $*"
	else
		echo "##### $(date '+%Y-%m-%d %H:%M:%S') $*"
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

	fabric-ca-client enroll -d --enrollment.profile tls -u https://$NAME:$PASSWORD@$CA_HOST_NAME:7054 -M $MSP_DIR --csr.hosts $HOST_NAME --csr.names C=US,ST="California",O=${ORG},OU=COP

	# Copy CA certs
	mkdir -p $MSP_DIR/tlscacerts
	mkdir -p $MSP_DIR/cacerts
	cp $ORG_MSP_DIR/cacerts/* $MSP_DIR/tlscacerts
	cp $ORG_MSP_DIR/cacerts/* $MSP_DIR/cacerts
}

function logr() {
	log $*
	log $* >>$RUN_SUMPATH
}
