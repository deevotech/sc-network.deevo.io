#!/bin/bash
usage() { echo "Usage: $0 [-n <name>]" 1>&2; exit 1; }
while getopts ":n:" o; do
    case "${o}" in
        n)
            n=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${n}" ] ; then
    usage
fi
logpid() { while sleep 0.02; do  ps -p $1 -opcpu= -opmem= -oetime=; done; }
pid=$(pidof ${n})
mkdir -p ./data
mkdir -p ./data/logs
if [ -f ./data/logs/pid-${n}.file ] ; then
    prevpid=$(cat ./data/logs/pid-${n}.file)
    kill $prevpid
fi
echo $! > ./data/logs/pid-${n}.file & 
