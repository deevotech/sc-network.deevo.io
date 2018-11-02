set -e

source $(dirname "$0")/env.sh

# Wait for setup to complete sucessfully
usage() { echo "Usage: $0 [-g <orgname>] [-n <numberOfReplicas>] [-d <TLS directory of orderer>]" 1>&2; exit 1; }
while getopts ":g:n:d:" o; do
    case "${o}" in
        g)
            g=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
		d)
            d=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ] || [ -z "${n}" ] || [ -z "${d}" ] ; then
    usage
fi

ORG=${g}
mkdir -p ${DATA}
mkdir -p data/logs
export RUN_SUMPATH=data/logs/replicasTLS-${g}.log

function initVars() {
	initOrgVars $ORG
	export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
	export FABRIC_CA_CLIENT_HOME=/var/hyperledger/ordering/ca-client
	mkdir -p /var/hyperledger/ordering/ca-client
	rm -rf /var/hyperledger/ordering/ca-client/*

	export NODE_ORG_ADMIN=replicas-admin
	export NODE_ORG_ADMIN_PW=replicas-admin-pw

	export ORDERING_NODE_CRT_DIR=$ORG_HOME/certs
	export ORDERING_NODE_KEY_DIR=$ORG_HOME/keys

	export ORDERER_CERT_DIR=${d}
}

function enrollCAAdmin() {
	logr "Enrolling with $ENROLLMENT_URL as bootstrap identity ..."
	fabric-ca-client enroll -d -u $ENROLLMENT_URL
}

function registerNodesIdentities() {
	logr "Registering admin identity with $NODE_ORG_ADMIN:$NODE_ORG_ADMIN_PW"
	# The admin identity has the "admin" attribute which is added to ECert by default
	fabric-ca-client register -d --id.name $NODE_ORG_ADMIN --id.secret $NODE_ORG_ADMIN_PW --id.attrs "admin=true:ecert" --id.affiliation $ORG

	ORDERING_ADMIN_MSP_DIR=$ADMIN_CERT_DIR/msp
	ORDERING_ADMIN_TLS_DIR=$ADMIN_CERT_DIR/tls
	mkdir -p $ORDERING_ADMIN_MSP_DIR
	mkdir -p $ORDERING_ADMIN_TLS_DIR
	genMSPCerts bft.node.admin $NODE_ORG_ADMIN $NODE_ORG_ADMIN_PW $ORG $CA_HOST $ORDERING_ADMIN_MSP_DIR

	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_ADMIN_TLS_DIR/client.crt
	cp $ORDERING_ADMIN_MSP_DIR/keystore/* $ORDERING_ADMIN_TLS_DIR/client.key

	# Copy admin certs
	mkdir -p $ORDERING_ADMIN_MSP_DIR/admincerts
	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORDERING_ADMIN_MSP_DIR/admincerts/cert.pem
	mkdir -p $ORG_MSP_DIR/admincerts
	cp $ORDERING_ADMIN_MSP_DIR/signcerts/* $ORG_MSP_DIR/admincerts/cert.pem

    mkdir -p $ORDERING_NODE_CRT_DIR
    mkdir -p $ORDERING_NODE_KEY_DIR

    cp $ORDERER_CERT_DIR/server.crt $ORDERING_NODE_CRT_DIR/cert1000.pem
	cp $ORDERER_CERT_DIR/server.key $ORDERING_NODE_KEY_DIR/cert1000.key

	# create users for ordering nodes
	for ((c = 0; c < $n; c++)); do
		NODE_HOST_NAME="bft.node.${c}"
		NODE_USER="node-${c}"
		NODE_PASS="node-${c}-pw"
		fabric-ca-client register -d --id.name $NODE_USER --id.secret $NODE_PASS --id.affiliation $ORG

		ORDERING_NODE_MSP_DIR=$USER_CERT_DIR/$NODE_HOST_NAME/msp

		mkdir -p $ORDERING_NODE_MSP_DIR
		genMSPCerts $NODE_HOST_NAME $NODE_USER $NODE_PASS $ORG $CA_HOST $ORDERING_NODE_MSP_DIR

		cp $ORDERING_NODE_MSP_DIR/signcerts/* $ORDERING_NODE_CRT_DIR/cert${c}.pem
		cp $ORDERING_NODE_MSP_DIR/keystore/* $ORDERING_NODE_KEY_DIR/cert${c}.key
	done
}

function getCACerts() {
	logr "Getting CA certificates ..."
	logr "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
	mkdir -p $ORG_MSP_DIR
	fabric-ca-client getcacert -d -u $ENROLLMENT_URL -M $ORG_MSP_DIR
	mkdir -p $ORG_MSP_DIR/tlscacerts
	cp $ROOT_TLS_CERTFILE  $ORG_MSP_DIR/tlscacerts

	# Copy CA cert
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
	cp $ROOT_TLS_CERTFILE  $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
}

function main() {
	initVars
	enrollCAAdmin
	getCACerts
	registerNodesIdentities
}

main