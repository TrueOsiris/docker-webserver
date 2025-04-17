#!/bin/bash
set -e

initfile=webserver.initialised

# ensure TZ is set (default to Europe/Brussels)
TZ=${TZ:-Europe/Brussels}
export TZ

# 1) create group if it doesn't exist
if ! getent group "$WEB_GROUP" >/dev/null; then
  groupadd --non-unique --gid "$WEB_GID" "$WEB_GROUP"
fi

# 2) create user if it doesn't exist
if ! id -u "$WEB_USER" >/dev/null 2>&1; then
  useradd --no-create-home \
          --shell /usr/sbin/nologin \
          --uid "$WEB_UID" \
          --gid "$WEB_GID" \
          "$WEB_USER"
fi

# 3) patch Apache’s runtime user/group
sed -ri \
  -e "s#^export APACHE_RUN_USER=.*#export APACHE_RUN_USER=$WEB_USER#" \
  -e "s#^export APACHE_RUN_GROUP=.*#export APACHE_RUN_GROUP=$WEB_GROUP#" \
  /etc/apache2/envvars

# 4) ensure volumes are owned by the chosen UID:GID
chown -R "${WEB_UID}:${WEB_GID}" /www /config

# 5) initialize php.ini if needed
if [ ! -f /config/php.ini ]; then
  echo "Initializing php.ini with timezone $TZ"
  cp /usr/local/etc/php/php.ini-production /config/php.ini
  sed -i "s#^;date.timezone =.*#date.timezone = $TZ#" /config/php.ini
  mkdir -p /etc/php/8.2/apache2
  ln -sf /config/php.ini /etc/php/8.2/apache2/php.ini
  ln -sf /config/php.ini /usr/local/etc/php/php.ini
  ln -sf /config/php.ini /etc/php/php.ini
  /usr/sbin/a2enmod rewrite
fi

# 6) one‐time webroot bootstrap
if [ -f /config/$initfile ]; then
  echo "Initial configuration already done."
else
  mkdir -p /www
  chmod -R 777 /config /www
  chown -R "${WEB_UID}:${WEB_GID}" /www /config

  if [ ! -f /www/index.php ]; then
    cat >/www/index.php <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
    <link rel="shortcut icon" href="/favicon.ico?v=2" type="image/x-icon">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
        padding-right: 10px;
        display: inline-block;
        color: black;
    }
    </style>
</head>
<body>
    <div><? echo "PHP is working. Version: ".phpversion(); ?></div><br><br>
    <div id="mydiv" hidden>JQuery is functional. Click me!</div>
</body>
</html>
EOL
  fi

  echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$initfile
  date >> /config/$initfile
fi

# 7) drop into Apache foreground process
exec apache2-foreground
