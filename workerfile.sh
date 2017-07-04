#!/bin/bash
workerfile=/synced/workers/$(echo $HOST_HOSTNAME)
if [ -f $workerfile ]; then
  if [ "$(( $(date +"%s") - $(stat -c "%Y" $workerfile) ))" -gt "5" ]; then
    echo "test" > $workerfile
  fi
else
  echo "test" > $workerfile
fi
