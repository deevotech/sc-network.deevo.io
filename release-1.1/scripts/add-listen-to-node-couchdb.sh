#!/bin/bash
set -e
usage() { echo "Usage: $0 [-i <ip>]" 1>&2; exit 1; }
while getopts ":i:" o; do
    case "${o}" in
        i)
            i=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${i}" ]; then
    usage
fi
curl -X PUT http://admin:admin@127.0.0.1:5984/_node/couchdb@${i}/_config/admins/admin -d '"admin"'
curl -X PUT http://admin:admin@127.0.0.1:5984/_node/couchdb@${i}/_config/chttpd/bind_address -d '"0.0.0.0"'