#!/bin/bash

set -e
initfile=webserver.initialised

if [ -f /config/php.ini ]; then
	echo "Setting timezone TZ to default Europe/Brussels or to the docker parameter TZ"
	TZ=${TZ:-"Europe/Brussels"}
	echo "Replacing timezone in /etc/php/7.4/apache2/php.ini ..."
	sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g" /etc/php/7.4/apache2/php.ini 2>&1
	echo "Moving /etc/php/7.4/apache2/php.ini to /config/php.ini ..."
	mv /etc/php/7.4/apache2/php.ini /config/php.ini 2>&1
	echo "Creating a symlink to source /config/php.ini at target /etc/php/7.4/apache2/php.ini ..."
	ln -s /config/php.ini /etc/php/7.4/apache2/php.ini 2>&1
	echo "Enabling PHP mod rewrite ..."
	/usr/sbin/a2enmod rewrite 2>&1
fi

if [ -f /config/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
        chmod -R 777 /config 2>&1
        chmod -R 777 /www 2>&1
        if [ ! -f /www/index.php ]; then
           cat >/www/index.php <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
	<script src="jquery.min.js"></script>
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
 <div><? echo "php7.4 is working"; ?></div><div id="mydiv" hidden >JQuery is functional</div>	
</body>
</html>
EOL
           cp /usr/share/javascript/jquery/jquery.min.js /www/
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$(echo $initfile)
        date >> /config/$(echo $initfile)
fi


        
