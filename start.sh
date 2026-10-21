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

# 5) initialize php.ini if needed, and always (re)link it: links live in the image and are lost on recreate
if [ ! -f /config/php.ini ]; then
  echo "Initializing php.ini with timezone $TZ"
  cp /usr/local/etc/php/php.ini-production /config/php.ini
  sed -i "s#^;date.timezone =.*#date.timezone = $TZ#" /config/php.ini
fi
ln -sf /config/php.ini /usr/local/etc/php/php.ini

# 6) PHP2Shell (CVE-2026-109618 / CVE-2026-109619) mitigation: auto = on only while PHP is unpatched
php2shell_patched() {
  # shellcheck disable=SC2016
  php -r '
    $fixed = ["8.2" => "8.2.35", "8.3" => "8.3.36", "8.4" => "8.4.27", "8.5" => "8.5.12"];
    $branch = PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;
    if (version_compare($branch, "8.2", "<")) exit(1);
    if (!isset($fixed[$branch])) exit(0);
    exit(version_compare(PHP_VERSION, $fixed[$branch], ">=") ? 0 : 1);'
}
case "${PHP2SHELL_MITIGATION:-auto}" in
  on|true|1)  mitigate=1 ;;
  off|false|0) mitigate=0 ;;
  *) if php2shell_patched; then mitigate=0; else mitigate=1; fi ;;
esac
if [ "$mitigate" = 1 ]; then
  echo "PHP $(php -r 'echo PHP_VERSION;'): PHP2Shell mitigation ENABLED (multipart/form-data requests are rejected)"
  a2enconf -q php2shell-mitigation
  printf 'session.upload_progress.enabled = Off\n' > /usr/local/etc/php/conf.d/zz-php2shell.ini
else
  echo "PHP $(php -r 'echo PHP_VERSION;'): PHP2Shell mitigation disabled"
  a2disconf -q php2shell-mitigation >/dev/null 2>&1 || true
  rm -f /usr/local/etc/php/conf.d/zz-php2shell.ini
fi

# 7) one‐time webroot bootstrap
if [ -f /config/$initfile ]; then
  echo "Initial configuration already done."
else
  mkdir -p /www
  chown -R "${WEB_UID}:${WEB_GID}" /www /config

  if [ ! -f /www/index.php ]; then
    cat >/www/index.php <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
    <link rel="shortcut icon" href="/favicon.ico?v=2" type="image/x-icon">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
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
    <div><?php echo "PHP is working. Version: " . phpversion(); ?></div><br><br>
    <div id="mydiv" hidden>JQuery is functional. Click me!</div>
</body>
</html>
EOL
  fi

  echo -e "Do not remove this file.\nIf you do, container will be fully reset on next start." > /config/$initfile
  date >> /config/$initfile
fi

# 8) drop into Apache foreground process
exec apache2-foreground
