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
        
        if [ ! -d /synced/www ]; then
           mkdir -p /synced/www
           echo "<? header('Location: /test.php'); ?>" > /synced/www/index.php
           #cp -TRv /tmp/fuelhive/ /synced/www/fuel/app/
           cp /usr/share/javascript/jquery/jquery.min.js /synced/www/
        fi
        if [ ! -d /synced/www/workers ]; then
           mkdir -p /synced/www/workers
        fi
        if [ ! -d /synced/www/managers ]; then
           mkdir -p /synced/www/managers
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /synced/$(echo $initfile)
        date >> /synced/$(echo $initfile)
fi
