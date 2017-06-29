# Hive Docker manager using shared, synced volume
FROM quantumobject/docker-baseimage:latest
MAINTAINER Tim Chaubet "tim@chaubet.be"

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y net-tools \
                       iputils-ping \
                       vim \
 && apt-get autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* 
 
# copy dhcp config files
COPY test.conf /tmp/test.conf
ADD test.conf /tmp/

### startup scripts ###

#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh
    
# the normal syntax does not work: VOLUME ["/var/lib/dhcp", "/etc/dhcp", "/scripts"]
# volumes defined here are created AT container start
#VOLUME /var/test
VOLUME ["/config"]

# Exposing http port
EXPOSE 80

CMD ["/sbin/my_init"]
