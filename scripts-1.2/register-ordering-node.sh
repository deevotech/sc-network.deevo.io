#!/bin/bash

SDIR=$(dirname "$0")
source $SDIR/env.sh
export RUN_SUMPATH=/data/logs/orderer.log
export RUN_FRONTEND=/data/logs/frontend.log
export DATA=/home/ubuntu/hyperledgerconfig/data

function enrollCAAdmin() {
	logr "Enrolling with $ENROLLMENT_URL as bootstrap identity ..."
	fabric-ca-client enroll -d -u $ENROLLMENT_URL
}

# Register any identities associated with a peer
function registerOrdererIdentities() {
	enrollCAAdmin

	fabric-ca-client register -d --id.name $CORE_PEER_ID --id.secret $ORDERER_PASS --id.type orderer --id.affiliation $ORG

	logr "Registering admin identity with $ADMIN_NAME:$ADMIN_PASS"
	# The admin identity has the "admin" attribute which is added to ECert by default
	fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "admin=true:ecert" --id.affiliation $ORG
}

function registerNodesIdentities() {
	FABRIC_CA_CLIENT_HOME=/var/hyperledger/ordering/ca-client
	export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server-config/rca.ordering.bft-cert.pem

	fabric-ca-client enroll -d -u https://rca-ordering-nodes-admin:rca-ordering-nodes-adminpw@$ORDERING_CA_HOST:7054
	NODE_ORG_ADMIN=ordering-nodes-admin
	NODE_ORG_ADMIN_PW=ordering-nodes-adminpw

	ORDERING_ORG_MSP_DIR=$ORDERING_CRYPTO_DIR/msp
	mkdir -p $ORDERING_ORG_MSP_DIR
	fabric-ca-client getcacert -d -u https://rca-ordering-nodes-admin:rca-ordering-nodes-adminpw@$ORDERING_CA_HOST:7054 -M $ORDERING_ORG_MSP_DIR
	mkdir -p $ORDERING_ORG_MSP_DIR/tlscacerts
	cp $ORDERING_ORG_MSP_DIR/cacerts/* $ORDERING_ORG_MSP_DIR/tlscacerts

	logr "Registering admin identity with $NODE_ORG_ADMIN:$NODE_ORG_ADMIN_PW"
	# The admin identity has the "admin" attribute which is added to ECert by defaultls
	fabric-ca-client register -d --id.name $NODE_ORG_ADMIN --id.secret $NODE_ORG_ADMIN_PW --id.attrs "admin=true:ecert" --id.affiliation $NODE_ORG

	ORDERING_ADMIN_MSP_DIR=$ORDERING_CRYPTO_DIR/admin/msp
	ORDERING_ADMIN_TLS_DIR=$ORDERING_CRYPTO_DIR/admin/tls
	mkdir -p $ORDERING_ADMIN_MSP_DIR
	mkdir -p $ORDERING_ADMIN_TLS_DIR
	genMSPCerts bft.node $NODE_ORG_ADMIN $NODE_ORG_ADMIN_PW $NODE_ORG $ORDERING_CA_HOST $ORDERING_ADMIN_MSP_DIR

	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_ADMIN_TLS_DIR/client.crt
	cp $ORDERING_ADMIN_MSP_DIR/keystore/* $ORDERING_ADMIN_TLS_DIR/client.key

	# Copy admin certs
	mkdir -p $ORDERING_ADMIN_MSP_DIR/admincerts
	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_ADMIN_MSP_DIR/admincerts/cert.pem
	mkdir -p $ORDERING_ORG_MSP_DIR/admincerts
	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_ORG_MSP_DIR/admincerts/cert.pem

	# create users for ordering nodes
	for ((c = 0; c < $NODE_COUNT; c++)); do
		NODE_HOST_NAME="bft.node.${c}"
		NODE_USER="node-${c}"
		NODE_PASS="node-${c}-pw"
		fabric-ca-client register -d --id.name $NODE_USER --id.secret $NODE_PASS --id.affiliation $NODE_ORG
        sleep 1

		ORDERING_NODE_MSP_DIR=$ORDERING_CRYPTO_DIR/$NODE_HOST_NAME/msp
		ORDERING_NODE_TLS_DIR=$ORDERING_CRYPTO_DIR/$NODE_HOST_NAME/tls

		mkdir -p $ORDERING_CRYPTO_DIR/$NODE_HOST_NAME
		genMSPCerts $NODE_HOST_NAME $NODE_USER $NODE_PASS $ORG $ORDERING_CA_HOST $ORDERING_NODE_MSP_DIR

		mkdir -p $ORDERING_NODE_TLS_DIR
		cp $ORDERING_NODE_MSP_DIR/signcerts/* $ORDERING_NODE_TLS_DIR/client.crt
		cp $ORDERING_NODE_MSP_DIR/keystore/* $ORDERING_NODE_TLS_DIR/client.key
		# Copy admin certs
		mkdir -p $ORDERING_NODE_MSP_DIR/admincerts
		cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_NODE_MSP_DIR/admincerts/cert.pem
	done
}

function getCACerts() {
	#logr "Getting CA certificates ..."
	#logr "Getting CA certs for organization $ORG and storing in $ORG_MSP"
	mkdir -p $ORG_MSP
	fabric-ca-client getcacert -d -u $ENROLLMENT_URL -M $ORG_MSP
	mkdir -p $ORG_MSP/tlscacerts
	cp $ORG_MSP/cacerts/* $ORG_MSP/tlscacerts

	# Copy CA cert
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
	cp $ORG_MSP/cacerts/* $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
}

function main() {
    export FABRIC_CA_CLIENT_HOME=/var/hyperledger/ordering/ca-client
    mkdir -p /var/hyperledger/crypto/
    rm -rf /var/hyperledger/crypto/
    mkdir -p /var/hyperledger/crypto/org
    rm -rf /var/hyperledger/crypto/org/*
    mkdir -p /var/hyperledger/crypto/ordering
    rm -rf /var/hyperledger/crypto/ordering/*
	mkdir -p $FABRIC_CA_CLIENT_HOME
    rm -rf $FABRIC_CA_CLIENT_HOME/*
    mkdir -p data
    mkdir -p data/logs
    export RUN_SUMPATH=./data/logs/ca-${ORG}.log
    export ORG_ADMIN_HOME=/var/hyperledger/crypto/org/admin
    export ORDERING_CRYPTO_DIR=/var/hyperledger/crypto/ordering
    export FABRIC_CA_CLIENT_HOME=/var/hyperledger/ordering/ca-client
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server-config/rca.ordering.bft-cert.pem
    export ORDERING_CA_HOST=rca.ordering-nodes.deevo.io
    export NODE_COUNT=4
    export NODE_ORG=ordering-nodes
    export ORG_MSP=/var/hyperledger/crypto/org/msp
    export ENROLLMENT_URL=https://rca-ordering-nodes-admin:rca-ordering-nodes-adminpw@$ORDERING_CA_HOST:7054

    getCACerts

	registerNodesIdentities
    mkdir -p ${DATA}
    rm -rf ${DATA}/*
	# Copy certs
    mkdir -p ${DATA}/keys
    rm -rf ${DATA}/keys/*
	#cp $ORDERER_CERT_DIR/tls/server.crt ./data/keys/cert1000.pem
	for ((c = 0; c < $NODE_COUNT; c++)); do
		NODE_HOST_NAME="bft.node.${c}"
		cp ${ORDERING_CRYPTO_DIR}/${NODE_HOST_NAME}/tls/client.crt ${DATA}/keys/cert${c}.pem
	done
	# Copy private key
	#cp $ORDERER_CERT_DIR/tls/server.key ./data/keys/keystore.pem 
    mkdir -p ${DATA}/orgs
    mkdir -p ${DATA}/orgs/orderering
    cp -R /var/hyperledger/crypto/ordering/* ${DATA}/orgs/orderering/
    cp -R /var/hyperledger/crypto/org/* ${DATA}/orgs/orderering/
    echo "done"
}

main
