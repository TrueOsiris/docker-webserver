#!/bin/bash

set -e
initfile=$(echo $HOST_HOSTNAME)\.initialised
if [ -f /synced/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no completion file ###
        #wget https://apt.dockerproject.org/repo/pool/testing/d/docker-engine/docker-engine_17.05.0~ce~rc3-0~ubuntu-zesty_amd64.deb \
        # -O /tmp/docker-engine.deb
        #dpkg -i /tmp/docker-engine.deb
        
        
        # create shared subfolder
        #if [ ! -d /shared/docker-install ]; then
        #   mkdir -p /shared/docker-install
        #fi
        #if [ ! -d /synced/folderstartup ]; then
        #   mkdir -p /synced/folderstartup
        #fi
        #if [ -f /synced/testfile ]; then
        #   date >> /synced/testfile 
        #else 
        #   echo -e "Testfile created." > /synced/testfile
        #fi
        #cp /tmp/base.conf /shared/
        #cp /tmp/base.conf /synced/
        
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /synced/$(echo $initfile)
        date >> /synced/$(echo $initfile)
fi
