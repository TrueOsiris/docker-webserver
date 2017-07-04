# Hive Docker manager using shared, synced volume
FROM quantumobject/docker-baseimage:latest
MAINTAINER Tim Chaubet "tim@chaubet.be"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y net-tools \
                       iputils-ping \
                       iptables \
                       bridge-utils \
                       vim \
                       libltdl7 \
                       dnsutils \
                       software-properties-common \
                       python-software-properties \
 && apt-get -f -y install 
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8
RUN apt-get update \
 && apt-get install -y --allow-unauthenticated docker-ce 
RUN apt-get autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* 
 
# copy base config files
# these will be moved to the volumes using the startup script
COPY base.conf /tmp/base.conf
ADD base.conf /tmp/

### startup scripts ###

#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

# add dhcpd daemon to runit
RUN mkdir -p /etc/service/nodefile /var/log/nodefile ; sync
COPY nodefile.sh /etc/service/nodefile/run
RUN chmod +x /etc/service/nodefile/run \
    && cp /var/log/cron/config /var/log/nodefile/ 
    
# the normal syntax does not work: VOLUME ["/var/lib/dhcp", "/etc/dhcp", "/scripts"]
# volumes defined here are created AT container start
#VOLUME /var/test
VOLUME ["/synced", "/shared", "/data", "/var/run/docker.sock"]

# Exposing http port
EXPOSE 80

CMD ["/sbin/my_init"]
