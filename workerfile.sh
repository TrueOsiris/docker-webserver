#!/bin/bash
workerfile=/synced/workers/$(echo $HOST_HOSTNAME)
function reachnode {
  pingtest=$(ping -w 2 -c 1 $1 2>&1)
  pingtest=$( [[ $pingtest =~ bytes\ from\ ([a-z0-9]*)\.[a-z]*\ \(.* ]] && echo ${BASH_REMATCH[1]} )
  if [ "$pingtest" = "$1" ]; then
    echo "\"$1\":\"up\"" >> $workerfile
  else
    echo "\"$1\":\"down\"" >> $workerfile
  fi
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
      echo "{" > $workerfile
      for node in $(<$f)
      do
        if [ "$HOST_HOSTNAME" = "$node" ]; then
          echo "\"$node\":\"up\"" >> $workerfile
        else
          reachnode $node
        fi
      done
      echo "}" >> $workerfile
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
