# Hive

Docker Hive Cluster
For now, it's just an idea.
I'm trying to manage containers within a single swarm, using a synced volume.

docker create \
 -p 4567:80 \
 -v /mnt/docker-nfs/hive/shared:/shared \
 -v /mnt/docker-dataset/hive/synced:/synced \
 -e PGID=983 \
 -e PUID=983 \
 -e TZ=Europe/Brussels \
 -e HOST_HOSTNAME=$(hostname) \
 -e HOST_IP=$(ip addr show enp0s3 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) \
 --name hive  \
 --restart=always \
 -v "/var/run/docker.sock:/var/run/docker.sock" \
 trueosiris/hive

docker container start hive
