# syntax=docker/dockerfile:1

# Pinned to a digest by the CI workflow; override for local builds,
# e.g. --build-arg BASE_IMAGE=php:8.4-apache-trixie
ARG BASE_IMAGE=php:8.5-apache-trixie
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="webserver" \
      org.opencontainers.image.description="Apache + PHP webserver with /www and /config volumes" \
      org.opencontainers.image.source="https://github.com/TrueOsiris/docker-webserver"

ENV TZ=Europe/Brussels \
    APACHE_DOCUMENT_ROOT=/www \
    WEB_USER=www-data \
    WEB_GROUP=www-data \
    PHP2SHELL_MITIGATION=auto

# Debian security updates, vim, and the GD extension (JPEG + PNG).
# The -dev packages are only needed to compile GD and are purged again; their runtime libraries are kept.
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends vim; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get install -y --no-install-recommends libjpeg62-turbo-dev libpng-dev zlib1g-dev; \
    docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" gd; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    extdir="$(php -r 'echo ini_get("extension_dir");')"; \
    ldd "$extdir"/*.so \
      | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
      | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    php -r 'exit(function_exists("imagecreatefromjpeg") && function_exists("imagecreatefrompng") ? 0 : 1);'

# DocumentRoot is resolved by Apache at runtime from $APACHE_DOCUMENT_ROOT (note the single quotes)
RUN set -eux; \
    sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf; \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY conf/webserver.conf conf/php2shell-mitigation.conf /etc/apache2/conf-available/
COPY conf/php-webserver.ini /usr/local/etc/php/conf.d/zz-webserver.ini
RUN a2enmod rewrite && a2enconf webserver

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /www
VOLUME ["/www", "/config"]
EXPOSE 80
# healthy = Apache answers with any status below 500 (an empty docroot returning 403 is still a running server)
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --start-interval=2s --retries=3 \
  CMD code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost/) && [ "$code" -gt 0 ] && [ "$code" -lt 500 ] || exit 1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]