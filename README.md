# webserver

![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060)
[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/webserver?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/webserver/)
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/webserver?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/webserver/)
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/webserver?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/webserver/)
![Github stars](https://badgen.net/github/stars/trueosiris/docker-webserver?icon=github&label=stars)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-webserver?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/TrueOsiris/docker-webserver)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-webserver)



Base webserver with 2 external volumes : /config & /www \
/config holds all apache2 & php7.0 config files \
/www is the entire webroot \

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
