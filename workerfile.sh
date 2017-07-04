#!/bin/bash
workerfile=/synced/workers/$(echo $HOST_HOSTNAME)
function reachnode {
  pingtest=$(ping -w 2 -c 1 $1)
  echo $pingtest >> $workerfile
}
function gen_workerfile {
  for f in /synced/managers/*
  do
    partofswarm=false
    for node in $(<$f)
    do
      if [ "$HOST_HOSTNAME" = "$node" ]; then
        partofswarm=true
      fi
    done
    if [ $partofswarm = true ]; then
      for node in $(<$f)
      do
        if [ "$HOST_HOSTNAME" = "$node" ]; then
          echo "$node;up" >> $workerfile
        else
          reachnode $node
        fi
      done
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
