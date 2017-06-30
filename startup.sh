#!/bin/bash

set -e

if [ -f /shared/hive.setup.initialised ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no completion file ###
        
        # create shared subfolder
        if [ ! -d /shared/docker-install ]; then
           mkdir -p /shared/docker-install
           wget https://apt.dockerproject.org/repo/pool/testing/d/docker-engine/docker-engine_17.05.0~ce~rc3-0~ubuntu-zesty_amd64.deb \
             -o /shared/docker-engine.deb
        fi
        if [ ! -d /synced/folderstartup ]; then
           mkdir -p /synced/folderstartup
        fi
        if [ -f /synced/testfile ]; then
           date >> /synced/testfile 
        else 
           echo -e "Testfile created." > /synced/testfile
        fi
        cp /tmp/base.conf /shared/
        cp /tmp/base.conf /synced/
        
        echo -e "Do not remove this file.\nIf you do, root password will be reset to the one in" \
                "the config" \
                "file.\n" > /shared/hive.setup.initialised
        date >> /shared/hive.setup.initialised
fi
