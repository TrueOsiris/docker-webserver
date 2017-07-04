#!/bin/bash
isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ "$isManager" != "" ]; then
  if [ -f /synced/$(echo $HOST_HOSTNAME).nodes.list ]; then
    if [ "$(( $(date +"%s") - $(stat -c "%Y" /synced/$(echo $HOST_HOSTNAME).nodes.list) ))" -gt "60" ]; then
      docker node ls --format {{.Hostname}} > /synced/$(echo $HOST_HOSTNAME).nodes.list
    fi
  else
    docker node ls --format {{.Hostname}} > /synced/$(echo $HOST_HOSTNAME).nodes.list
  fi
fi

