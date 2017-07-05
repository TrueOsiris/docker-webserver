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

        #apache2 conf adaptations
        a2enmod rewrite
        chown -R www-data:www-data /synced/www /var/log/apache2
        sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/synced\/www\/' /etc/apache2/sites-enabled/000*.conf
        #sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php7/apache2/php.ini
        #sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
        #sed -i -e "s@\$ALLOW_CUSTOM_SERVERS.*@\$ALLOW_CUSTOM_SERVERS = TRUE;@g" /var/www/mywebsql/config/servers.php
        rm -R /var/www/html/
        #to fix error relate to ip address of container apache2
        echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
        ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /synced/$(echo $initfile)
        date >> /synced/$(echo $initfile)
fi
