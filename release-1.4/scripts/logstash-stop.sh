#!/bin/bash
source $(dirname "$0")/env.sh
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
mkdir -p $LOGDIR
if [ -f $LOGDIR/pid-${n}.file ] ; then
    prevpid=$(cat $LOGDIR/pid-${n}.file)
    kill $prevpid
fi
echo $! > $LOGDIR/pid-${n}.file & 
