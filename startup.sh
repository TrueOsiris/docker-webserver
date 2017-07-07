#!/bin/bash

set -e
initfile=$(echo $HOST_HOSTNAME)\.initialised
if [ -f /synced/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
        
        if [ ! -d /synced/workers ]; then
           mkdir -p /synced/workers
        fi
        if [ ! -d /synced/managers ]; then
           mkdir -p /synced/managers
        fi
        if [ ! -d /synced/www ]; then
           mkdir -p /synced/www
           git clone git://github.com/fuel/fuel.git /synced/www/
           cd /synced/www 
           composer install --prefer-dist
           composer install --prefer-dist
           echo "<? header('Location: /public/'); ?>" > /synced/www/index.php
           
        fi

        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /synced/$(echo $initfile)
        date >> /synced/$(echo $initfile)
fi
