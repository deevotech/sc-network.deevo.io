#!/bin/bash

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

rm -rf couchdb
git clone https://github.com/apache/couchdb -b 2.3.x

cd couchdb/ && \
./configure --disable-docs && make release
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
sudo rm -rf /home/couchdb/
sudo cp -R rel/couchdb /home/couchdb
sudo chown -R couchdb:couchdb /home/couchdb
sudo find /home/couchdb -type d -exec chmod 0770 {} \;

cd ..

if [ -d /opt/couchdb ] ;  then
sudo rm -rf /opt/couchdb
fi
sudo mkdir /opt/couchdb
sudo chown couchdb:couchdb /opt/couchdb
sudo chmod 777 -R /opt/couchdb
sudo mkdir /opt/couchdb/data
sudo mkdir /opt/couchdb/logs

echo "Copy config files"
if [ ${d} -eq 1 ] ; then 
    echo "Restart"
	sudo cp ../config/localdeevo.ini /home/couchdb/etc/local.ini
	echo "-name couchdb@${i}" >> ../config/vm.args
else
    echo "Init"
	sudo cp ../config/local.ini /home/couchdb/etc/local.ini
fi
sudo cp ../config/vm.args /home/couchdb/etc/vm.args
sudo chmod -R 0774 /home/couchdb/etc

sudo rm -rf /var/log/couchdb
sudo mkdir /var/log/couchdb
sudo chown couchdb:couchdb /var/log/couchdb

echo "Config CouchDB service"
sudo rm -rf /etc/sv/couchdb
sudo rm -rf /etc/service/couchdb
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
echo "Start service"
sudo runsv /etc/service/couchdb &

sleep 5
echo "Service status"
sudo sv status couchdb

