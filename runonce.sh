#!/bin/bash
a2enmod rewrite
chown -R www-data:www-data /synced/www /var/log/apache2
sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/synced\/www\//' /etc/apache2/sites-enabled/000*.conf
rm -R /var/www/html/
echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
