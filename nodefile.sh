#!/bin/bash

### create a json file for each manager every 61 seconds

isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ "$isManager" != "" ]; then
  managerfile=/synced/www/managers/$HOST_HOSTNAME.json
  t=$(docker node list --format {{.Hostname}} | awk '{print "{ \"node\":\""$0"\" },"}')
  t="[ ${t::-1} ]"
  if [ -f $managerfile ]; then
    if [ "$(( $(date +"%s") - $(stat -c "%Y" $managerfile )))" -gt "60" ]; then
      echo $t > $managerfile
    fi
  else
    echo $t > $managerfile
  fi
fi
