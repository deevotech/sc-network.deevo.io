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
logpid() { while sleep 1; do  ps -p $1 -o pcpu= -o pmem= -o etime=; done; }
pid=$(pidof ${n})
logpid $pid > ./data/logs/pid-${n}.log 2>&1 &