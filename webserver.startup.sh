#!/bin/bash

set -e
initfile=$(echo $HOST_HOSTNAME)\webserver.initialised
if [ -f /config/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
        
        mv /etc/php/7.0/apache2/php.ini /config/php.ini
        ln -s /config/php.ini /etc/php/7.0/apache2/php.ini
        
        if [ ! -f /www/index.php ]; then
           echo "<? echo "php7.0 is working"; ?>" > /www/index.php
           cp /usr/share/javascript/jquery/jquery.min.js /www/
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$(echo $initfile)
        date >> /config/$(echo $initfile)
fi
