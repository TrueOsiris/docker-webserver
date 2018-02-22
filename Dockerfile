# Hive Docker manager using shared, synced volume
FROM quantumobject/docker-baseimage:latest
MAINTAINER Tim Chaubet "tim@chaubet.be"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update 
RUN apt-get dist-upgrade -y 
RUN apt-get install -y net-tools \
                       libapache2-mod-php7.0 \
                       iputils-ping \
                       apache2 \
                       php7.0 \
                       php7.0-mysql \
                       git \
                       jq \
                       libjs-jquery \
 && apt-get autoremove -y \
 && apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* 


# copy base config files
# these will be moved to the volumes using the startup script
# ADD www /tmp/www

### startup scripts ###

RUN mkdir -p /etc/my_init.d
COPY webserver.startup.sh /etc/my_init.d/webserver.startup.sh
RUN chmod +x /etc/my_init.d/webserver.startup.sh
    
# add apache2 deamon to runit
RUN mkdir -p /etc/service/apache2  /var/log/apache2 ; sync 
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run \
    && cp /var/log/cron/config /var/log/apache2/ \
    && chown -R www-data /var/log/apache2
    
COPY runonce.sh /sbin/runonce
RUN chmod +x /sbin/runonce; sync \
    && /bin/bash -c /sbin/runonce \
    && rm /sbin/runonce

VOLUME ["/config", "/www"]

COPY apache2.conf /etc/apache2/apache2.conf

EXPOSE 80

CMD ["/sbin/my_init"]
