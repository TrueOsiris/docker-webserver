#!/bin/bash
isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ "$isManager" != "" ]; then
  managerfile=/synced/managers/$HOST_HOSTNAME
  if [ -f $managerfile ]; then
    if [ "$(( $(date +"%s") - $(stat -c "%Y" $managerfile )))" -gt "60" ]; then
      docker node ls --format {{.Hostname}} > $managerfile
    fi
  else
    docker node ls --format {{.Hostname}} > $managerfile
  fi
fi
