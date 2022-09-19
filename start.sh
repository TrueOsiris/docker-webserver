#!/bin/bash

set -e
initfile=webserver.initialised

if [ ! -f /config/php.ini ]; then
	echo "Setting timezone TZ to default Europe/Brussels or to the docker parameter TZ"
	TZ=${TZ:-"Europe/Brussels"}
	cp /usr/local/etc/php/php.ini-production /config/php.ini 2>&1
	echo "Replacing timezone in php.ini ..."
	sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g" /config/php.ini 2>&1
	#echo "Moving /etc/php/8.2/apache2/php.ini to /config/php.ini ..."
	#mv /etc/php/8.2/apache2/php.ini /config/php.ini 2>&1
	echo "Creating a symlink to source /config/php.ini at target /etc/php/8.2/apache2/php.ini ..."
	mkdir -p /etc/php/8.2/apache2 2>&1
	ln -s /config/php.ini /etc/php/8.2/apache2/php.ini 2>&1
	ln -s /config/php.ini /etc/php/php.ini 2>&1
	ln -s /config/php.ini /usr/local/etc/php/php.ini 2>&1
	echo "Enabling PHP mod rewrite ..."
	/usr/sbin/a2enmod rewrite 2>&1
fi

if [ -f /config/$(echo $initfile) ]; then
        echo 'initial configuration already done. index.php exists.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
	mkdir -p /www 2>&1
        chmod -R 777 /config 2>&1
        chmod -R 777 /www 2>&1
	chown -R www-data:www-data /www 2>&1
	chown -R www-data:www-data /config
        if [ ! -f /www/index.php ]; then
           cat >/www/index.php <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
	<script src="https://code.jquery.com/jquery-3.6.1.min.js"></script>
	<script>
		$(document).ready(function(){
			$("#mydiv").show();
			$("#mydiv").click(function(){
				$(this).hide();
			});
		});
	</script>
	<style>
		div {
			/* width: 40%; */
			padding-right: 10px;
			display: inline-block;
			color: black;
		}
	</style>
</head>
<body>
 <div><? echo "PHP is working. Version: ".phpversion(); ?></div><br><br><div id="mydiv" hidden >JQuery is functional. Click me!</div>	
</body>
</html>
EOL
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$(echo $initfile)
        date >> /config/$(echo $initfile)
fi
service apache2 start
tail -f /var/log/apache2/access.log
