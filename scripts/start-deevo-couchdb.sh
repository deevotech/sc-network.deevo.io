#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() { echo "Usage: $0 [-r <restart_or_init>]" 1>&2; exit 1; }
while getopts ":g:n:" o; do
    case "${o}" in
        r)
            r=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${r}" ] ; then
    usage
fi
# remove couchdb database
# restart couchdb server
#sudo kill $(pidof runsv)
sudo sv stop /etc/service/couchdb
if [ -f /etc/service/couchdb/supervise/lock ] ; then
sudo rm /etc/service/couchdb/supervise/lock
fi
if [ ${r} -eq 1 ] ; then
	if [ -d /opt/couchdb ] ;  then
	sudo rm -rf /opt/couchdb
	fi
	sudo mkdir /opt/couchdb
	sudo mkdir /opt/couchdb/data
	sudo chmod 777 -R /opt/couchdb
	sudo cp ./localdeevo.ini /home/couchdb/etc/local.ini
	rm -rf /ect/sv/couchdb/log/*
fi

#sudo runsv /etc/service/couchdb
sudo sv start /etc/service/couchdb
sleep 5
