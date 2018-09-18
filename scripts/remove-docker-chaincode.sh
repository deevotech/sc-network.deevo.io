#!/bin/bash
chaincodeImages=`docker images | grep "^dev-peer" | awk '{print $3}'`
if [ "$chaincodeImages" != "" ]; then
  # log "Removing chaincode docker images ..."
   docker rmi -f $chaincodeImages > /dev/null
fi
docker kill $(docker ps -q)
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
docker rmi $(docker images -a -q)

