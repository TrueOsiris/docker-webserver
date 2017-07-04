#!/bin/bash
workerfile=/synced/workers/$(echo $HOST_HOSTNAME)
if [ -f $workerfile ]; then
  if [ "$(( $(date +"%s") - $(stat -c "%Y" $workerfile) ))" -gt "5" ]; then
    echo "test" > $workerfile
    for f in /synced/managers/*.nodes
    do
      partofswarm=
      echo "checking $f" >> $workerfile
    done
  fi
else
  echo "test" > $workerfile
fi
