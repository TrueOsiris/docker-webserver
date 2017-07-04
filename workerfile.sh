#!/bin/bash
#isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
#if [ "$isManager" != "" ]; then
  if [ -f /synced/workers/$(echo $HOST_HOSTNAME) ]; then
    if [ "$(( $(date +"%s") - $(stat -c "%Y" /synced/workers/$(echo $HOST_HOSTNAME)) ))" -gt "5" ]; then
      echo "test" > /synced/workers/$(echo $HOST_HOSTNAME)
    fi
  else
    echo "test" > /synced/workers/$(echo $HOST_HOSTNAME)
  fi
#fi
