#!/bin/bash
workerfile=/synced/workers/$(echo $HOST_HOSTNAME)
if [ -f $workerfile ]; then
  if [ "$(( $(date +"%s") - $(stat -c "%Y" $workerfile) ))" -gt "4" ]; then
    echo "test" > $workerfile
    for f in /synced/managers/*
    do
      partofswarm=no
      echo "checking $f" >> $workerfile
      for word in $(<$f)
      do
        if [ "$HOST_HOSTNAME" = "$word" ];
          echo "worker $HOST_HOSTNAME is part of $f" >> $workerfile
          partofswarm=yes
        fi
      done
    done
  fi
else
  echo "test" > $workerfile
fi
