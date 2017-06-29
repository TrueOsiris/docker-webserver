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

# Exposing http port
EXPOSE 80
