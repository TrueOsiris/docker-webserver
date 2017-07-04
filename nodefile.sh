#!/bin/bash
echo nodefile running
isManager=$(docker node ls --format {{.Hostname}} 2>/dev/null)
if [ "$isManager" != "" ]; then
  docker node ls --format {{.Hostname}} > /synced/nodes.list
fi

