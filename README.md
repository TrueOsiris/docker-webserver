# webserver

Base webserver with 2 external volumes : /config & /www \
/config holds all apache2 & php7.0 config files \
/www is the entire webroot \
\
docker create \
 -p 4567:80 \
 -v /some/host/folder/www:/www \
 -v /some/host/folder/config:/config \
 -e PGID=983 \
 -e PUID=983 \
 -e TZ=Europe/Brussels \
 -e HOST_HOSTNAME=$(hostname) \
 -e HOST_IP=$(ip addr show enp0s3 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) \
 --name webserver  \
 --restart=unless-stopped \
 -v "/var/run/docker.sock:/var/run/docker.sock" \
 trueosiris/webserver

docker container start webserver

docker exec -it webserver /bin/bash

docker logs -f webserver
