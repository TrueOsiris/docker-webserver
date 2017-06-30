#!/bin/bash
echo nodefile running
isManager=$(docker node list 2>/dev/null)
if [ isManager != '' ]
  docker node ls --format {{.Hostname}} > nodes.list
fi
