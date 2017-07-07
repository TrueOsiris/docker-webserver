#!/bin/bash
isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ "$isManager" != "" ]; then
  managerfile=/synced/managers/$HOST_HOSTNAME
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
