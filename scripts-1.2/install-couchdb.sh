#!/bin/sh

set -e
export LC_ALL=C && \
source ~/.bashrc && \
source /etc/environment && \
source ~/.profile;
usage() { echo "Usage: $0 [-d <restart_or_init>] [ -i <ip_of_server> ]" 1>&2; exit 1; }
while getopts ":d:i:" o; do
    case "${o}" in
        d)
            d=${OPTARG}
            ;;
        i)
            i=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${d}" ] || [ -z "${i}" ]; then
    usage
fi
sudo apt-get update || true
sudo apt-get --no-install-recommends -y install \
    build-essential pkg-config runit erlang \
    libicu-dev libmozjs185-dev libcurl4-openssl-dev

wget http://apache-mirror.rbc.ru/pub/apache/couchdb/source/2.2.0/apache-couchdb-2.2.0.tar.gz

tar -xvzf apache-couchdb-2.2.0.tar.gz
cd apache-couchdb-2.2.0/ && \
./configure && make release
USER="couchdb"
EXISTS=$( cat /etc/passwd | grep ${USER} | sed -e 's/:.*//g') 
#echo ${EXISTS}
#if [ "${EXISTS}" -eq "couchdb" ] ; then
sudo adduser --system \
        --no-create-home \
        --shell /bin/bash \
        --group --gecos \
        "CouchDB Administrator" couchdb
#fi
#sudo kill $(pidof runsv)
sudo rm -rf /home/couchdb/*
sudo cp -R rel/couchdb /home/couchdb
sudo chown -R couchdb:couchdb /home/couchdb
sudo find /home/couchdb -type d -exec chmod 0770 {} \;
sudo sh -c 'chmod 0644 /home/couchdb/etc/*'

if [ -d /opt/couchdb ] ;  then
sudo rm -rf /opt/couchdb
fi
sudo mkdir /opt/couchdb
sudo mkdir /opt/couchdb/data
sudo chmod 777 -R /opt/couchdb
if [ ${d} -eq 1 ] ; then 
	sudo cp ../config-1.2/localdeevo.ini /home/couchdb/etc/local.ini
	echo "-name couchdb@${i}" >> ../config-1.2/vm.args
else
	sudo cp ../config-1.2/local.ini /home/couchdb/etc/local.ini
fi
sudo cp ../config-1.2/vm.args /home/couchdb/etc/vm.args
sudo rm -rf /var/log/couchdb
sudo mkdir /var/log/couchdb
sudo chown couchdb:couchdb /var/log/couchdb

sudo rm -rf /etc/sv/couchdb
sudo mkdir /etc/sv/couchdb
sudo mkdir /etc/sv/couchdb/log

cat > run << EOF
#!/bin/sh
export HOME=/home/couchdb
exec 2>&1
exec chpst -u couchdb /home/couchdb/bin/couchdb
EOF

cat > log_run << EOF
#!/bin/sh
exec svlogd -tt /var/log/couchdb
EOF

sudo mv ./run /etc/sv/couchdb/run
sudo mv ./log_run /etc/sv/couchdb/log/run

sudo chmod u+x /etc/sv/couchdb/run
sudo chmod u+x /etc/sv/couchdb/log/run

sudo ln -s /etc/sv/couchdb/ /etc/service/couchdb
sudo runsv /etc/service/couchdb &

sleep 5
sudo sv status couchdb

