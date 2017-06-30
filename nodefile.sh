#!/bin/bash
echo nodefile running
isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ isManager != '' ]
  docker node ls --format {{.Hostname}} > nodes.list
fi
