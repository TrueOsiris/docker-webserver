# webserver

![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060)
[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/webserver?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/webserver/)
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/webserver?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/webserver/)
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/webserver?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/webserver/)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-webserver?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/TrueOsiris/docker-webserver)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-webserver)



Base webserver with 2 external volumes : /config & /www \
/config holds all apache2 & php8.2 config files \
/www is the entire webroot \

[Github](https://github.com/TrueOsiris/docker-webserver) [Dockerhub](https://hub.docker.com/repository/docker/trueosiris/webserver)

minimal:
```
      docker create \
      -p 4567:80 \
      -v /some/host/folder/www:/www \
      -v /some/host/folder/config:/config \
      trueosiris/webserver
```
more options:
```
      docker create \
      -p 4567:80 \
      -v /some/host/folder/www:/www \
      -v /some/host/folder/config:/config \
      -e APACHE_DOCUMENT_ROOT=/www \
      -e PGID=983 \
      -e PUID=983 \
      -e TZ=Europe/Brussels \
      -e HOST_HOSTNAME=$(hostname) \
      -e HOST_IP=$(ip addr show enp0s3 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) \
      --name webserver  \
      --restart=unless-stopped \
      -v "/var/run/docker.sock:/var/run/docker.sock" \
      trueosiris/webserver
```

docker compose

```yaml
x-volume-localtime:
  &etclocaltime
  type: 'bind'
  source: /etc/localtime
  target: /etc/localtime
  read_only: true
x-volume-webdefault-webroot:
  &webdefaultwebroot
  type: 'bind'
  source: /mnt/user/docker_compose/web/default/www
  target: /www
  bind:
    create_host_path: true  
x-volume-webdefault-config:
  &webdefaultconfig
  type: 'bind'
  source: /mnt/user/docker_compose/web/default/config
  target: /config
  bind:
    create_host_path: true

services:
  webserver:
    image: trueosiris/webserver
    environment:
      - APACHE_DOCUMENT_ROOT=/www 
      - PGID=1000 
      - PUID=1000 
      - TZ=Europe/Brussels 
      - HOST_HOSTNAME=$(hostname) 
      - HOST_IP=$(ip addr show enp0s3 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) 
    restart: unless-stopped
    network_mode: bridge     
    volumes: 
      - <<: *etclocaltime
      - <<: *webdefaultwebroot 
      - <<: *webdefaultconfig 
    ports:
      - 8031:80  
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 60s
      timeout: 10s
      retries: 5
```
