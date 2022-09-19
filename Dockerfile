FROM php:8.2.0RC2-apache-bullseye

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update -y && \
    apt-get upgrade -y && \
    apt-get install -y  apt-utils \
			libzlcore0.13 zlib1g-dev \
			libpng-dev \
			libjpeg-dev

ENV APACHE_DOCUMENT_ROOT /www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ && docker-php-ext-install gd
WORKDIR /www/
VOLUME [ "/www", "/config" ]
COPY start.sh /sbin/start.sh
RUN chmod +x /sbin/start.sh; sync; \
 && /sbin/start.sh
COPY apache2.conf /etc/apache2/apache2.conf
EXPOSE 80
