ARG BASE_IMAGE=php:8.4-apache-trixie
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Brussels \
    APACHE_DOCUMENT_ROOT=/www \
    WEB_USER=www-data \
    WEB_GROUP=www-data \
    WEB_UID=33 \
    WEB_GID=33 \
    PHP2SHELL_MITIGATION=auto

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      zlib1g-dev \
      libpng-dev \
      libjpeg-dev \
      vim && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# adjust the DocumentRoot in Apache’s config
RUN sed -ri -e "s!/var/www/html!$APACHE_DOCUMENT_ROOT!g" \
           /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!$APACHE_DOCUMENT_ROOT!g" \
           /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# build GD
RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install gd

# hardening + PHP2Shell (CVE-2026-109618 / CVE-2026-109619) mitigation, toggled by start.sh
COPY php2shell-mitigation.conf /etc/apache2/conf-available/php2shell-mitigation.conf
RUN a2enmod rewrite && \
    printf 'ServerTokens Prod\nServerSignature Off\n' > /etc/apache2/conf-available/zz-hardening.conf && \
    a2enconf zz-hardening && \
    printf 'expose_php = Off\n' > /usr/local/etc/php/conf.d/zz-hardening.ini

COPY start.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /www
VOLUME ["/www","/config"]
EXPOSE 80
HEALTHCHECK --interval=60s --timeout=10s --start-period=20s --retries=3 \
  CMD curl -fsS -o /dev/null http://localhost/ || exit 1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
