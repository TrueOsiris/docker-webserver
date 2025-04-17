FROM php:apache-bullseye

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Brussels \
    APACHE_DOCUMENT_ROOT=/www \
    WEB_USER=www-data \
    WEB_GROUP=www-data \
    WEB_UID=33 \
    WEB_GID=33

RUN apt update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
      apt-utils \
      libzlcore0.13 zlib1g-dev \
      libpng-dev \
      libjpeg-dev \
      vim && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# adjust the DocumentRoot in Apache’s config
RUN sed -ri -e "s!/var/www/html!$APACHE_DOCUMENT_ROOT!g" \
           /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!$APACHE_DOCUMENT_ROOT!g" \
           /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# build GD
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ && \
    docker-php-ext-install gd

COPY start.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /www
VOLUME ["/www","/config"]
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
