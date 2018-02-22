#!/bin/bash

set -e
initfile=$(echo $HOST_HOSTNAME)\.initialised
if [ -f /config/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
        
        if [ ! -f /www/index.php ]; then
           echo "<? echo "php7.0 is working"; ?>" > /www/index.php
           cp /usr/share/javascript/jquery/jquery.min.js /www/
           cp -TRv /tmp/www/ /www/
           git clone https://github.com/TrueOsiris/spotweb.git /www/spotweb
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$(echo $initfile)
        date >> /config/$(echo $initfile)
fi
