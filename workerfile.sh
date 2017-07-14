#!/bin/bash

### this will create a workerfile for each node in each swarm, based on the hostname, refreshing every 5 seconds.

workerfile=/synced/www/workers/$(echo $HOST_HOSTNAME).json
function reachnode {
  pingtest=$(ping -w 2 -c 1 $1 2>&1)
  pingtest=$( [[ $pingtest =~ bytes\ from\ ([a-z0-9]*)\.[a-z]*\ \(.* ]] && echo ${BASH_REMATCH[1]} )
  if [ "$pingtest" = "$1" ]; then
    echo "\"status\":\"up\" }," >> $workerfile
  else
    echo "\"status\":\"down\" }," >> $workerfile
  fi
}
function gen_workerfile {
  for f in /synced/www/managers/*.json
  do
    partofswarm=false
    nodes=$(cat $f | jq -r '.[].manager')
    for node in $nodes
    do
      if [ "$HOST_HOSTNAME" = "$node" ]; then
        partofswarm=true
      fi
    done
    if [ $partofswarm = true ]; then
      echo "[" > $workerfile
      for node in $nodes
      do
        echo "{ \"node\":\"$node\"," >> $workerfile
        if [ "$HOST_HOSTNAME" = "$node" ]; then
          echo "\"status\":\"up\" }," >> $workerfile
        else
          reachnode $node
        fi
      done
      # strip that last comma from the workerfile string
      echo $(awk '{a[NR]=$0} END {for (i=1;i<NR;i++) print a[i];sub(/.$/,"",a[NR]);print a[NR]}' $workerfile) "]" > $workerfile
    fi
  done
}
if [ -f $workerfile ]; then
  if [ "$(( $(date +"%s") - $(stat -c "%Y" $workerfile) ))" -gt "4" ]; then
    gen_workerfile
  fi
else
  gen_workerfile
fi
