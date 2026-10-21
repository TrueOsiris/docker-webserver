# webserver

![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060)
[![Build and publish image](https://github.com/TrueOsiris/docker-webserver/actions/workflows/docker-image.yml/badge.svg)](https://github.com/TrueOsiris/docker-webserver/actions/workflows/docker-image.yml)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-webserver?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/TrueOsiris/docker-webserver)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-webserver)

A small, self-maintaining **Apache + PHP 8.5** webserver image with two volumes:

- **`/www`**: the web root. Put your site here.
- **`/config`**: persistent configuration (`php.ini` and extra Apache config).

```
ghcr.io/trueosiris/webserver
```

[GitHub repository](https://github.com/TrueOsiris/docker-webserver) ·
[Container package](https://github.com/TrueOsiris/docker-webserver/pkgs/container/webserver)

> **Moved from Docker Hub.** The image is only published on the GitHub Container Registry now.
> Replace `trueosiris/webserver` with `ghcr.io/trueosiris/webserver`. See [Migrating from Docker Hub](#migrating-from-docker-hub).

## Contents

- [Features](#features)
- [What's inside](#whats-inside)
- [Tags](#tags)
- [Quick start](#quick-start)
- [Volumes](#volumes)
- [Environment variables](#environment-variables)
- [File ownership (UID/GID mapping)](#file-ownership-uidgid-mapping)
- [Configuring PHP](#configuring-php)
- [Configuring Apache](#configuring-apache)
- [Healthcheck](#healthcheck)
- [PHP2Shell (CVE-2026-109618 / CVE-2026-109619)](#php2shell-cve-2026-109618--cve-2026-109619)
- [Updating](#updating)
- [Migrating from Docker Hub](#migrating-from-docker-hub)
- [Extending the image](#extending-the-image)
- [Building locally](#building-locally)
- [How the image is built (CI/CD)](#how-the-image-is-built-cicd)
- [Security notes](#security-notes)
- [Troubleshooting](#troubleshooting)
- [Repository layout](#repository-layout)

## Features

- Official `php:8.5-apache-trixie` base (Debian 13), with Debian security updates applied at build time.
- **Rebuilt automatically**: whenever the upstream PHP image changes (checked every 6 hours) and at least once a day.
- Multi-arch: `linux/amd64` and `linux/arm64`.
- `php.ini` lives on the `/config` volume, so your PHP settings survive image updates.
- Extra Apache config can be dropped into `/config/apache2/*.conf`.
- Runs Apache as any UID/GID you choose (`WEB_UID`/`WEB_GID`), so files on bind mounts get the right owner.
- `mod_rewrite` and `.htaccess` (`AllowOverride All`) enabled; directory listings disabled.
- Hardened defaults: no Apache/PHP version disclosure, `TRACE` disabled.
- Built-in Docker `HEALTHCHECK`.
- Automatic [PHP2Shell](#php2shell-cve-2026-109618--cve-2026-109619) mitigation while the bundled PHP is unpatched.
- Signed build provenance (GitHub artifact attestations).

## What's inside

| Component | Version (at the time of writing) |
|-----------|----------------------------------|
| Base image | `php:8.5-apache-trixie` (Debian 13 "trixie") |
| PHP | 8.5.12 (`mod_php`, `mpm_prefork`) |
| Apache | 2.4.69 |
| Demo page | jQuery 4.0.0 (loaded from code.jquery.com with SRI) |

The exact PHP version of every build is in its `php8.5.x` tag and in the container log.

**PHP extensions:** Core, ctype, curl, date, dom, fileinfo, filter, **gd** (JPEG + PNG), hash, iconv,
json, lexbor, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_sqlite, Phar, posix, random, readline,
Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, uri, xml, xmlreader, xmlwriter,
Zend OPcache, zlib.

Database drivers such as `mysqli`/`pdo_mysql`/`pdo_pgsql` are **not** included. See [Extending the image](#extending-the-image).

**Apache modules:** the Debian defaults plus `php` and `rewrite`.

**Tools:** `curl`, `vim`.

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build of `main`. |
| `php8.5` | Latest build on the PHP 8.5 branch. |
| `php8.5.12` | Latest build with that exact PHP version. |
| `YYYYMMDD` | Last build of that day, e.g. `20261021`. |
| `sha-xxxxxxx` | Build of that git commit. |

Older tags such as `php8.4.27` stay available but are no longer updated.

## Quick start

```sh
docker run -d --name webserver \
  -p 8080:80 \
  -v /srv/web/www:/www \
  -v /srv/web/config:/config \
  --restart unless-stopped \
  ghcr.io/trueosiris/webserver
```

Open <http://localhost:8080>. On first start (with an empty web root) a demo page is created that shows
`PHP is working. Version: 8.5.x` and a jQuery test. Replace it with your own site.

### Docker Compose

```yaml
services:
  webserver:
    image: ghcr.io/trueosiris/webserver:latest
    container_name: webserver
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      TZ: Europe/Brussels
      WEB_UID: 1000        # owner of the files on the host
      WEB_GID: 1000
      # APACHE_DOCUMENT_ROOT: /www/public
      # PHP2SHELL_MITIGATION: auto
    volumes:
      - ./www:/www
      - ./config:/config
```

```sh
docker compose up -d
docker compose logs -f webserver
```

The image has its own healthcheck, so you don't need a `healthcheck:` section.

## Volumes

| Path | Contents |
|------|----------|
| `/www` | Web root (the default `DocumentRoot`). Everything here is served by Apache/PHP. |
| `/config/php.ini` | Your PHP configuration. Created from `php.ini-production` on first start. |
| `/config/apache2/*.conf` | Optional extra Apache configuration, loaded at startup. |
| `/config/webserver.initialised` | Marker file: the one-time setup (demo page) has run. Delete it to run the setup again. |

Both volumes are created as anonymous volumes when you don't mount them, but then your data is lost when
the container is removed. Always mount them.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `Europe/Brussels` | Container timezone. Also written to `date.timezone` in `/config/php.ini` when that file is first created. |
| `APACHE_DOCUMENT_ROOT` | `/www` | Apache `DocumentRoot`, applied at startup. Use a path inside `/www`, e.g. `/www/public` for Laravel/Symfony. |
| `WEB_USER` | `www-data` | User Apache and PHP run as. Created if it doesn't exist. |
| `WEB_GROUP` | `www-data` | Group Apache and PHP run as. Created if it doesn't exist. |
| `WEB_UID` | `33` | UID of `WEB_USER`. `0` (root) is refused. |
| `WEB_GID` | `33` | GID of `WEB_GROUP`. |
| `PUID` / `PGID` | | Aliases for `WEB_UID` / `WEB_GID`, used when those aren't set. |
| `WEB_CHOWN` | `true` | On startup, give `/www`, `/config` and the document root to `WEB_UID:WEB_GID`. Set to `false` to leave ownership alone. |
| `PHP2SHELL_MITIGATION` | `auto` | `auto`, `on` or `off`. See [PHP2Shell](#php2shell-cve-2026-109618--cve-2026-109619). |

Invalid values (non-numeric IDs, UID 0, a relative document root) stop the container with a clear error in the log.

## File ownership (UID/GID mapping)

Apache's worker processes run as `WEB_USER` with `WEB_UID:WEB_GID`. Set these to the owner of your
host folder so PHP can write uploads, caches and sessions, and so you can edit the files on the host:

```sh
id -u; id -g          # on the host, e.g. 1000 / 1000
docker run ... -e WEB_UID=1000 -e WEB_GID=1000 ghcr.io/trueosiris/webserver
```

On every start the entrypoint:

1. creates `WEB_USER`/`WEB_GROUP`, or changes their IDs to `WEB_UID`/`WEB_GID`;
2. runs Apache's workers as that user;
3. changes the owner of everything in `/www`, `/config` and the document root that isn't owned by `WEB_UID:WEB_GID` yet. Only files that differ are touched, so restarts stay fast.

Set `WEB_CHOWN=false` if the files must keep their own owner (for example a read-only or shared mount).
A failed `chown` (e.g. on a read-only mount) only logs a warning.

## Configuring PHP

Edit **`/config/php.ini`** on the volume and restart the container:

```sh
docker restart webserver
```

The file is created once, from PHP's `php.ini-production`, and never overwritten. To start over,
delete it and restart.

Rather than editing the whole file you can also mount extra `.ini` files into `/usr/local/etc/php/conf.d/`:

```sh
-v ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini:ro
```

```ini
; uploads.ini
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
```

The image sets `expose_php = Off` in `conf.d/zz-webserver.ini`. Settings in `conf.d` override `php.ini`.

OPcache is enabled and re-checks changed files every 2 seconds (`opcache.revalidate_freq`), so edits to
PHP files can take up to 2 seconds to appear.

## Configuring Apache

- **`.htaccess`** files work everywhere in `/www` (`AllowOverride All`), including `mod_rewrite` rules.
- **Global config / virtual hosts**: put `*.conf` files in `/config/apache2/` and restart. For example
  `/config/apache2/site.conf`:

  ```apache
  <VirtualHost *:80>
      ServerName example.com
      DocumentRoot /www/example.com
      <Directory /www/example.com>
          AllowOverride All
          Require all granted
      </Directory>
  </VirtualHost>
  ```

  Test your config with `docker exec webserver apache2ctl configtest`.

The image's own settings are in `/etc/apache2/conf-enabled/webserver.conf` (`ServerName localhost`,
`ServerTokens Prod`, `ServerSignature Off`, `TraceEnable Off`). Your files are loaded after it, so you can override them.

Apache listens on port 80 inside the container. Terminate HTTPS in a reverse proxy (Traefik, Caddy,
nginx, Nginx Proxy Manager, ...) in front of it.

## Healthcheck

The image defines a Docker `HEALTHCHECK`: every 60 seconds it requests `http://localhost/` from inside
the container. Any HTTP answer below `500` counts as healthy, so an empty web root (`403`) doesn't mark the
container unhealthy, but PHP fatal errors on `/` (`500`) or a dead Apache do.

```sh
docker inspect --format '{{.State.Health.Status}}' webserver
```

## PHP2Shell (CVE-2026-109618 / CVE-2026-109619)

PHP2Shell (published 2026-10-21) is a pair of critical, unauthenticated remote code execution bugs in PHP's
multipart request parsing. They are fixed in **PHP 8.2.35, 8.3.36, 8.4.27 and 8.5.12**.

This image ships PHP 8.5.12 or newer, so it is **not vulnerable**. As a safety net, the entrypoint checks the PHP
version on every start. When PHP is older than the fixed release, it blocks the known attack vector:

- Apache rejects every `multipart/form-data` request with `403`, before PHP parses the body;
- PHP's `session.upload_progress` is disabled.

**This breaks file uploads** while it is active. The container log always says which mode is active:

```
[entrypoint] PHP 8.5.12: PHP2Shell mitigation disabled
```

| `PHP2SHELL_MITIGATION` | Behaviour |
|------------------------|-----------|
| `auto` (default) | Enabled only while the bundled PHP is vulnerable. |
| `on` | Always enabled. |
| `off` | Never enabled. Only use this if you accept the risk. |

If you run an older tag (or the old Docker Hub image), update now. See [Updating](#updating).

## Updating

```sh
docker pull ghcr.io/trueosiris/webserver:latest
docker rm -f webserver
docker run -d --name webserver ...    # same options as before
```

or with Compose:

```sh
docker compose pull && docker compose up -d
```

Your site and configuration are on the volumes and are kept. For automatic updates you can use a tool such as
[Watchtower](https://containrrr.dev/watchtower/) or Diun.

If you want to stay on one PHP branch, use the `php8.5` tag instead of `latest`.

## Migrating from Docker Hub

`trueosiris/webserver` on Docker Hub is no longer updated: it is stuck at PHP 8.2 on Debian 11 and
**vulnerable to PHP2Shell**. To migrate:

1. Change the image to `ghcr.io/trueosiris/webserver:latest`. Keep the same volumes.
2. Recreate the container (`docker compose pull && docker compose up -d`).
3. Check the log for the PHP version line.

What changed compared to the old image:

- PHP 8.5 instead of 8.2. Check your code against the [PHP 8.3](https://www.php.net/manual/en/migration83.php),
  [8.4](https://www.php.net/manual/en/migration84.php) and [8.5](https://www.php.net/manual/en/migration85.php) migration guides.
- Debian 13 instead of Debian 11.
- `WEB_UID`/`WEB_GID` now actually change the user Apache runs as, and `WEB_USER`/`WEB_GROUP` work.
  Before, files were chowned to `WEB_UID` but Apache kept running as UID 33.
- `/www` is no longer made world-writable (`chmod 777`). Use `WEB_UID`/`WEB_GID` instead.
- `APACHE_DOCUMENT_ROOT` can now be changed at runtime.
- The image has a built-in healthcheck. You can remove your own `healthcheck:` section.
- The old `start.sh` is now `/usr/local/bin/entrypoint.sh`.

## Extending the image

Use this image as a base and add PHP extensions with the official helper scripts:

```dockerfile
FROM ghcr.io/trueosiris/webserver:php8.5

# MySQL/MariaDB support
RUN docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql

# extensions that need system libraries, e.g. intl and zip
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libicu-dev libzip-dev; \
    docker-php-ext-install -j"$(nproc)" intl zip; \
    rm -rf /var/lib/apt/lists/*

# PECL extensions (need the build tools in $PHPIZE_DEPS, removed again afterwards)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends $PHPIZE_DEPS; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    apt-get purge -y --auto-remove $PHPIZE_DEPS; \
    rm -rf /var/lib/apt/lists/* /tmp/pear

# more Apache modules
RUN a2enmod headers expires
```

## Building locally

```sh
git clone https://github.com/TrueOsiris/docker-webserver.git
cd docker-webserver
docker build -t webserver:local .
docker run --rm -p 8080:80 webserver:local
```

Use another PHP version with the `BASE_IMAGE` build argument. Any official `php:*-apache-*` image works:

```sh
docker build --build-arg BASE_IMAGE=php:8.4-apache-trixie -t webserver:php8.4 .
```

## How the image is built (CI/CD)

[`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml) runs:

| Trigger | What happens |
|---------|--------------|
| Push to `main` | Build, test and publish. |
| Pull request | Build and test only (nothing is pushed). |
| Every 6 hours | Rebuild **only if** the upstream `php:8.5-apache-trixie` digest changed, or the last build is older than 20 hours. Scheduled builds don't use the cache, so Debian updates are always included. |
| Manual (*Run workflow*) | Rebuild. Untick *force* to rebuild only when needed. |

Every build:

1. pins the base image to its exact digest;
2. builds an amd64 test image and runs a smoke test:
   - PHP executes;
   - `php.ini` is linked to `/config`;
   - `mod_rewrite` is enabled;
   - the container restarts on existing volumes;
   - the PHP2Shell mitigation works;
   - UID/GID mapping works and PHP can write to `/www`;
   - the healthcheck passes;
3. pushes the `linux/amd64` + `linux/arm64` image to `ghcr.io/trueosiris/webserver`;
4. publishes a signed build provenance attestation:

   ```sh
   gh attestation verify oci://ghcr.io/trueosiris/webserver:latest --owner TrueOsiris
   ```

All GitHub Actions are pinned to commit SHAs. To move to a new PHP minor version, change `PHP_VERSION` in the
workflow and the `BASE_IMAGE` default in the `Dockerfile`.

## Security notes

- Apache's master process runs as root (needed to bind port 80); the workers that execute PHP run as `WEB_USER`.
- `WEB_UID=0` is refused.
- Server version and `X-Powered-By` headers are hidden, `TRACE` is disabled, directory listings are off.
- `php.ini` defaults to PHP's production settings (`display_errors = Off`).
- Run the container behind an HTTPS reverse proxy, and use `--read-only` mounts (with `WEB_CHOWN=false`) for content PHP shouldn't change.
- Report security issues privately via [GitHub security advisories](https://github.com/TrueOsiris/docker-webserver/security/advisories/new).

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `403 Forbidden` on `/` | No `index.php`/`index.html` in the document root (directory listings are disabled). Add an index file, or delete `/config/webserver.initialised` and restart to recreate the demo page. |
| Uploads fail with `403` | The PHP2Shell mitigation is active: you're running a vulnerable PHP. Pull the latest image. Check the log line `PHP2Shell mitigation ...`. |
| PHP can't write files / `Permission denied` | Set `WEB_UID`/`WEB_GID` to the owner of the host folder, and keep `WEB_CHOWN=true`. |
| Changes to `php.ini` have no effect | Edit `/config/php.ini` (not a file inside the container) and restart. `docker exec webserver php --ini` shows which files are loaded. |
| Changed PHP files show old content | OPcache re-checks files every 2 s. Wait a moment, or set `opcache.revalidate_freq = 0` in `/config/php.ini`. |
| Apache doesn't start after adding a `.conf` | `docker logs webserver`, then fix or remove the file in `/config/apache2/`. |
| Wrong time in PHP | Set `TZ`, and update `date.timezone` in `/config/php.ini` (it is only written on first start). |

Debug shell: `docker exec -it webserver bash`. Run a one-off command: `docker run --rm ghcr.io/trueosiris/webserver php -v`.

## Repository layout

| Path | Purpose |
|------|---------|
| [`Dockerfile`](Dockerfile) | Image definition. |
| [`entrypoint.sh`](entrypoint.sh) | Startup script: user mapping, volumes, `php.ini`, PHP2Shell mitigation, demo page. |
| [`conf/webserver.conf`](conf/webserver.conf) | Global Apache settings and the `/config/apache2` include. |
| [`conf/php-webserver.ini`](conf/php-webserver.ini) | PHP settings baked into the image. |
| [`conf/php2shell-mitigation.conf`](conf/php2shell-mitigation.conf) | Apache rule that blocks `multipart/form-data` when the mitigation is on. |
| [`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml) | Build, test and publish workflow. |