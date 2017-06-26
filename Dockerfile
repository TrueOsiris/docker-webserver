# Hive Docker manager using shared, synced volume
FROM ubuntu:17.04

RUN apt-get update && \
    apt-get -y upgrade && \
    rm -rf /var/lib/apt/lists/* 

# Exposing http port
EXPOSE 80
