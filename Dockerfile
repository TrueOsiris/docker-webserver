FROM php:8.2-apache
ENV APACHE_DOCUMENT_ROOT /www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ && docker-php-ext-install gd
RUN rm -R /var/www/html
RUN chown -R www-data:www-data /www /var/log/apache2
WORKDIR /www/
VOLUME [ "/www", "/config" ]
COPY runonce.sh /sbin/runonce
RUN chmod +x /sbin/runonce; sync \
    && /bin/bash -c /sbin/runonce \
    && rm /sbin/runonce
COPY apache2.conf /etc/apache2/apache2.conf
EXPOSE 80

