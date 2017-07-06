#!/bin/bash

set -e
initfile=$(echo $HOST_HOSTNAME)\.initialised
if [ -f /synced/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file ###
        #wget https://apt.dockerproject.org/repo/pool/testing/d/docker-engine/docker-engine_17.05.0~ce~rc3-0~ubuntu-zesty_amd64.deb \
        # -O /tmp/docker-engine.deb
        #dpkg -i /tmp/docker-engine.deb
        
        
        if [ ! -d /synced/workers ]; then
           mkdir -p /synced/workers
        fi
        if [ ! -d /synced/managers ]; then
           mkdir -p /synced/managers
        fi
        if [ ! -d /synced/www ]; then
           mkdir -p /synced/www
        fi
        #if [ -f /synced/testfile ]; then
        #   date >> /synced/testfile 
        #else 
        #   echo -e "Testfile created." > /synced/testfile
        #fi
        #cp /tmp/base.conf /shared/
        #cp /tmp/base.conf /synced/
        git clone git://github.com/fuel/fuel.git /synced/www/
        cd /synced/www && composer install --prefer-dist
        cd /synced/www && composer install --prefer-dist
        echo "<? header('Location: /public/'); ?>" > /synced/www/index.php

        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /synced/$(echo $initfile)
        date >> /synced/$(echo $initfile)
fi
