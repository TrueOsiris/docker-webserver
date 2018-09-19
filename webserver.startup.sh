#!/bin/bash

set -e
initfile=webserver.initialised

TZ=${TZ:-"Europe/Brussels"}
sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g" /etc/php/7.0/apache2/php.ini

if [ -f /config/$(echo $initfile) ]; then
        echo 'initial configuration done.'
else    
        ### run once at container start IF no initialization file.
        ### if the .initialised file is removed, the container    
        ### will be reset to it's default state, unless the www
        ### folder is maintained.
        chmod -R 777 /config 2>/dev/null
        chmod -R 777 /www 2>/dev/null
        mv /etc/php/7.0/apache2/php.ini /config/php.ini
        ######  rm /etc/php/7.0/apache2/php.ini 2>&1
        ln -s /config/php.ini /etc/php/7.0/apache2/php.ini
        # Enabling PHP mod rewrite
        /usr/sbin/a2enmod rewrite 2>&1
        if [ ! -f /www/index.php ]; then
           #echo "<? echo 'php7.0 is working'; ?>" > /www/index.php
           cat >/www/index.php <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
	<script src="jquery.min.js"></script>
	<script>
		$(document).ready(function(){
			$("#mydiv").show();
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
 <div><? echo "php7.0 is working"; ?></div><div id="mydiv" hidden >JQuery is functional</div>	
	</script>
</body>
</html>
EOL
           cp /usr/share/javascript/jquery/jquery.min.js /www/
        fi
        echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$(echo $initfile)
        date >> /config/$(echo $initfile)
fi


        
