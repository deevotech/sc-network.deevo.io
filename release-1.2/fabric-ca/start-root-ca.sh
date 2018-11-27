#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-g <orgname>] [-u <bootstrap user>] [-p <bootstrap password>]" 1>&2
	exit 1
}
while getopts ":g:u:p:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	u)
		u=${OPTARG}
		;;
	p)
		p=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${u}" ] || [ -z "${p}" ]; then
	usage
fi

set -e
ORG=${g}
export FABRIC_CA_SERVER_HOME=$ROOT_DIR/server
export FABRIC_CA_SERVER_TLS_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=rca.${g}.deevo.io
export FABRIC_CA_SERVER_CSR_HOSTS=localhost
export FABRIC_CA_SERVER_DEBUG=true
export FABRIC_CA_SERVER_TLS_CERTFILE=$ROOT_DIR/keys/tls.rca.${g}.deevo.io.pem
export FABRIC_CA_SERVER_CA_CERTFILE=$ROOT_DIR/keys/rca.${g}.deevo.io.pem

export RUN_SUMPATH=$ROOT_DIR/logs/ca-${ORG}.log

BOOTSTRAP_USER=${u}
BOOTSTRAP_PASS=${p}
BOOTSTRAP_USER_PASS=$BOOTSTRAP_USER:$BOOTSTRAP_PASS

BOOTSTRAP_AUDITOR_ADMIN_NAME=auditor-admin
BOOTSTRAP_AUDITOR_ADMIN_PASS=auditor-admin-pw
BOOTSTRAP_AUDITOR_ADMIN=$BOOTSTRAP_AUDITOR_ADMIN_NAME:$BOOTSTRAP_AUDITOR_ADMIN_PASS

# Make folders and delete old files if existed
if [ ! -d $ROOT_DIR/keys ]; then
    mkdir -p $ROOT_DIR/keys
else 
    if [ -e $FABRIC_CA_SERVER_TLS_CERTFILE ]; then
        rm $FABRIC_CA_SERVER_TLS_CERTFILE
    fi
    if [ -e $FABRIC_CA_SERVER_CA_CERTFILE ]; then
        rm $FABRIC_CA_SERVER_CA_CERTFILE
    fi
fi
if [ ! -d $ROOT_DIR/logs ]; then
    mkdir -p $ROOT_DIR/logs
else 
    if [ -e $RUN_SUMPATH ]; then
        rm $RUN_SUMPATH
    fi
fi
if [ ! -d $FABRIC_CA_SERVER_HOME ]; then
    mkdir -p $FABRIC_CA_SERVER_HOME
else 
    rm -rf $FABRIC_CA_SERVER_HOME/*
fi

echo "# Version of config file
version: 1.2.0

# Server listening port (default: 7054)
port: 7054

# Enables debug logging (default: false)
debug: false

# Size limit of an acceptable CRL in bytes (default: 512000)
crlsizelimit: 512000

#############################################################################
crl:
  expiry: 24h

#############################################################################
registry:
  # Maximum number of times a password/secret can be reused for enrollment
  # (default: -1, which means there is no limit)
  maxenrollments: -1

  # Contains identity information which is used when LDAP is disabled
  identities:
    - name: ${BOOTSTRAP_USER}
      pass: ${BOOTSTRAP_PASS}
      type: admin
      affiliation: \"${g}\"
      attrs:
        hf.Registrar.Roles: \"admin,mod,client,user,auditor\"
        hf.Registrar.DelegateRoles: \"admin,mod,user,auditor\"
        hf.Revoker: true
        hf.GenCRL: true
        hf.Registrar.Attributes: \"*\"
        hf.AffiliationMgr: true
    - name: ${BOOTSTRAP_AUDITOR_ADMIN_NAME}
      pass: ${BOOTSTRAP_AUDITOR_ADMIN_PASS}
      type: admin
      affiliation: \"auditors\"
      attrs:
        hf.Registrar.Roles: \"auditor\"
        hf.Registrar.DelegateRoles: \"auditor\"
        hf.Revoker: true
        hf.GenCRL: true
        hf.Registrar.Attributes: \"*\"
        hf.AffiliationMgr: false

#############################################################################
#  Database section
#############################################################################
db:
  type: sqlite3
  datasource: fabric-ca-server.db
  tls:
      enabled: false
      certfiles:
      client:
        certfile:
        keyfile:

#############################################################################
# Affiliations section. Fabric CA server can be bootstrapped with the
# affiliations specified in this section. Affiliations are specified as maps.
#############################################################################
affiliations:
  $g: []
  auditors: []

#############################################################################
#  Signing section
#############################################################################
signing:
    default:
      usage:
        - digital signature
      expiry: 8760h
    profiles:
      ca:
        usage:
          - cert sign
          - crl sign
          - digital signature
          - key encipherment
        expiry: 43800h
        caconstraint:
          isca: true
          maxpathlen: 0
      tls:
        usage:
            - signing
            - key encipherment
            - server auth
            - client auth
            - key agreement
        expiry: 8760h

###########################################################################
#  Certificate Signing Request (CSR) section.
###########################################################################
csr:
  cn: fabric-ca-server
  names:
    - C: US
      ST: California
      L:
      O: ${g}
      OU: ${g}
  hosts:
    - ubuntu
    - localhost
  ca:
    expiry: 131400h
    pathlength: 1

#############################################################################
# BCCSP (BlockChain Crypto Service Provider) section is used to select which
# crypto library implementation to use
#############################################################################
bccsp:
    default: SW
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            # The directory used for the software file-based keystore
            keystore: msp/keystore

cacount:

cafiles:

intermediate:
  parentserver:
    url:
    caname:

  enrollment:
    hosts:
    profile:
    label:

  tls:
    certfiles:
    client:
      certfile:
      keyfile:
" >> $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml

for pid in $(pidof fabric-ca-server); do
    if [ $pid != $$ ]; then
        echo "Process is already running with PID $pid"
        kill $pid
    fi
done

fabric-ca-server init -b $BOOTSTRAP_USER_PASS

# Start the root CA

logr "Start CA server"
logr "Sleeping 3s to wait for CA server"

fabric-ca-server start --ca.certfile $FABRIC_CA_SERVER_HOME/ca-cert.pem -b $BOOTSTRAP_USER_PASS >$RUN_SUMPATH 2>&1 &
sleep 3
cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $ROOT_DIR/keys/rca.${g}.deevo.io.pem
echo "Success see in $RUN_SUMPATH"
