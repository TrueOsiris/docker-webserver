# webserver

![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060)
[![Build and publish image](https://github.com/TrueOsiris/docker-webserver/actions/workflows/docker-image.yml/badge.svg)](https://github.com/TrueOsiris/docker-webserver/actions/workflows/docker-image.yml)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-webserver?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/TrueOsiris/docker-webserver)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-webserver)



Base Apache + PHP 8.4 webserver with 2 external volumes : /config & /www \
/config holds php.ini \
/www is the entire webroot

The image is published on the GitHub Container Registry: **`ghcr.io/trueosiris/webserver`** \
It is no longer published on Docker Hub; replace `trueosiris/webserver` with `ghcr.io/trueosiris/webserver`.

[Github](https://github.com/TrueOsiris/docker-webserver) [Package](https://github.com/TrueOsiris/docker-webserver/pkgs/container/webserver)

The image is rebuilt automatically by GitHub Actions: on every push, whenever the upstream
`php:8.4-apache-trixie` base image changes (checked every 6 hours), and at least once a day to pick up
Debian security updates.

| Tag              | Description                                   |
|------------------|-----------------------------------------------|
| `latest`         | Latest build of `main`                        |
| `php8.4.x`       | Latest build with that exact PHP version      |
| `YYYYMMDD`       | Build of that day                             |
| `sha-xxxxxxx`    | Build of that git commit                      |


| Variable                 | Default           | Description                                            |
|--------------------------|-------------------|--------------------------------------------------------|
| `APACHE_DOCUMENT_ROOT`   | `/www`            | Apache’s DocumentRoot (fixed at build time)            |
| `WEB_USER`               | `www-data`        | Linux user Apache runs as                              |
| `WEB_GROUP`              | `www-data`        | Linux group Apache runs as                             |
| `WEB_UID`                | `33`              | UID to use (creates user if missing)                   |
| `WEB_GID`                | `33`              | GID to use (creates group if missing)                  |
| `TZ`                     | `Europe/Brussels` | Timezone for PHP (`date.timezone`)                     |
| `PHP2SHELL_MITIGATION`   | `auto`            | `auto`, `on` or `off`, see below                       |

## PHP2Shell (CVE-2026-109618 / CVE-2026-109619)

PHP 8.2.35, 8.3.36, 8.4.27 and 8.5.12 fix two critical unauthenticated remote code execution bugs.
Until the image contains a fixed PHP version, the container blocks the known attack vector:
Apache rejects every `multipart/form-data` request with `403` and PHP's `session.upload_progress` is disabled.
**This breaks file uploads.** The container log shows the PHP version and whether the mitigation is enabled.

- `PHP2SHELL_MITIGATION=auto` (default): enabled only when the bundled PHP is vulnerable.
- `PHP2SHELL_MITIGATION=on`: always enabled.
- `PHP2SHELL_MITIGATION=off`: never enabled. Only use this if you accept the risk.

Pull the image again (`docker pull ghcr.io/trueosiris/webserver`) and recreate the container to get the patched PHP.

## Usage

minimal:
```
      docker create \
      -p 4567:80 \
      -v /some/host/folder/www:/www \
      -v /some/host/folder/config:/config \
      ghcr.io/trueosiris/webserver
```
more options:
```
      docker create \
      -p 4567:80 \
      -v /some/host/folder/www:/www \
      -v /some/host/folder/config:/config \
      -e WEB_UID=983 \
      -e WEB_GID=983 \
      -e TZ=Europe/Brussels \
      --name webserver  \
      --restart=unless-stopped \
      ghcr.io/trueosiris/webserver
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
    image: ghcr.io/trueosiris/webserver
    environment:
      - WEB_UID=1000
      - WEB_GID=1000
      - TZ=Europe/Brussels
    restart: unless-stopped
    network_mode: bridge     
    volumes: 
      - <<: *etclocaltime
      - <<: *webdefaultwebroot 
      - <<: *webdefaultconfig 
    ports:
      - 8031:80  
    healthcheck:
      test: ["CMD", "curl", "-fsS", "-o", "/dev/null", "http://localhost:80"]
      interval: 60s
      timeout: 10s
      retries: 5
```
