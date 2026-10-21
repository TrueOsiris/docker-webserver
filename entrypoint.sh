#!/usr/bin/env bash
# Container entrypoint: maps the web user to WEB_UID/WEB_GID, prepares the /www and /config volumes,
# applies the PHP2Shell mitigation when needed, then execs the CMD (apache2-foreground by default).
set -Eeuo pipefail

log() { echo "[entrypoint] $*"; }
die() { echo "[entrypoint] ERROR: $*" >&2; exit 1; }

initfile=/config/webserver.initialised

export TZ="${TZ:-Europe/Brussels}"
export APACHE_DOCUMENT_ROOT="${APACHE_DOCUMENT_ROOT:-/www}"
WEB_USER="${WEB_USER:-www-data}"
WEB_GROUP="${WEB_GROUP:-www-data}"
# PUID/PGID are accepted for compatibility with older documentation of this image
WEB_UID="${WEB_UID:-${PUID:-33}}"
WEB_GID="${WEB_GID:-${PGID:-33}}"

[[ "$WEB_UID" =~ ^[0-9]+$ && "$WEB_GID" =~ ^[0-9]+$ ]] || die "WEB_UID and WEB_GID must be numeric (got '$WEB_UID:$WEB_GID')"
[ "$WEB_UID" -ne 0 ] || die "WEB_UID=0 is not allowed: Apache refuses to serve pages as root"
[[ "$APACHE_DOCUMENT_ROOT" == /* ]] || die "APACHE_DOCUMENT_ROOT must be an absolute path (got '$APACHE_DOCUMENT_ROOT')"
[ -e "/usr/share/zoneinfo/$TZ" ] || log "WARNING: unknown timezone TZ=$TZ"

# 1) web group and user, created or re-numbered to WEB_GID/WEB_UID
if getent group "$WEB_GROUP" >/dev/null; then
  if [ "$(getent group "$WEB_GROUP" | cut -d: -f3)" != "$WEB_GID" ]; then
    log "changing GID of group $WEB_GROUP to $WEB_GID"
    groupmod --non-unique --gid "$WEB_GID" "$WEB_GROUP"
  fi
else
  log "creating group $WEB_GROUP ($WEB_GID)"
  groupadd --non-unique --gid "$WEB_GID" "$WEB_GROUP"
fi

if id -u "$WEB_USER" >/dev/null 2>&1; then
  if [ "$(id -u "$WEB_USER")" != "$WEB_UID" ]; then
    log "changing UID of user $WEB_USER to $WEB_UID"
    usermod --non-unique --uid "$WEB_UID" "$WEB_USER"
  fi
  if [ "$(id -gn "$WEB_USER")" != "$WEB_GROUP" ]; then
    usermod --gid "$WEB_GROUP" "$WEB_USER"
  fi
else
  log "creating user $WEB_USER ($WEB_UID)"
  useradd --non-unique --no-create-home --home-dir /nonexistent --shell /usr/sbin/nologin \
          --uid "$WEB_UID" --gid "$WEB_GROUP" "$WEB_USER"
fi

# 2) Apache worker user/group: /etc/apache2/envvars only applies its defaults when these are unset
export APACHE_RUN_USER="$WEB_USER" APACHE_RUN_GROUP="$WEB_GROUP"

mkdir -p /www /config/apache2 "$APACHE_DOCUMENT_ROOT"

# 3) php.ini lives on the /config volume; the link is in the image, so recreate it on every start
if [ ! -f /config/php.ini ]; then
  log "creating /config/php.ini from php.ini-production (date.timezone = $TZ)"
  cp /usr/local/etc/php/php.ini-production /config/php.ini
  sed -i "s#^;date.timezone =.*#date.timezone = \"$TZ\"#" /config/php.ini
fi
ln -sfn /config/php.ini /usr/local/etc/php/php.ini

# 4) PHP2Shell (CVE-2026-109618 / CVE-2026-109619) mitigation: auto = on only while PHP is unpatched
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
  on|true|1)   mitigate=1 ;;
  off|false|0) mitigate=0 ;;
  *) if php2shell_patched; then mitigate=0; else mitigate=1; fi ;;
esac
php_version="$(php -r 'echo PHP_VERSION;')"
if [ "$mitigate" = 1 ]; then
  log "PHP $php_version: PHP2Shell mitigation ENABLED (multipart/form-data requests are rejected)"
  a2enconf -q php2shell-mitigation
  printf 'session.upload_progress.enabled = Off\n' > /usr/local/etc/php/conf.d/zz-php2shell.ini
else
  log "PHP $php_version: PHP2Shell mitigation disabled"
  a2disconf -q php2shell-mitigation >/dev/null 2>&1 || true
  rm -f /usr/local/etc/php/conf.d/zz-php2shell.ini
fi

# 5) one-time bootstrap of a demo page; remove /config/webserver.initialised to run it again
if [ -f "$initfile" ]; then
  log "initial configuration already done"
else
  if [ ! -e "$APACHE_DOCUMENT_ROOT/index.php" ] && [ ! -e "$APACHE_DOCUMENT_ROOT/index.html" ]; then
    log "creating demo page $APACHE_DOCUMENT_ROOT/index.php"
    cat >"$APACHE_DOCUMENT_ROOT/index.php" <<'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>replaceme</title>
    <link rel="shortcut icon" href="/favicon.ico?v=2" type="image/x-icon">
    <script src="https://code.jquery.com/jquery-4.0.0.min.js" integrity="sha384-fgGyf7Mo7DURSOMnOy7ed+dkq5Job205Gnzu6QIg0BOHKaqt4D76Dt8VlDCzcMHV" crossorigin="anonymous"></script>
    <script>
    $(function () {
        $("#mydiv").show().on("click", function () {
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
    <div id="mydiv" style="display: none">jQuery is functional. Click me!</div>
</body>
</html>
EOL
  fi
  printf 'Do not remove this file.\nIf you do, the demo page is recreated on the next start when no index file exists.\n%s\n' "$(date)" > "$initfile"
fi

# 6) volumes owned by WEB_UID:WEB_GID; only touches entries that differ, so restarts stay fast
if [ "${WEB_CHOWN:-true}" = true ]; then
  for dir in /www /config "$APACHE_DOCUMENT_ROOT"; do
    find "$dir" \( ! -user "$WEB_UID" -o ! -group "$WEB_GID" \) -exec chown -h "$WEB_UID:$WEB_GID" {} + \
      || log "WARNING: could not change ownership of everything in $dir (read-only mount?)"
  done
fi

# 7) hand over to the CMD (apache2-foreground)
if [ "$#" -eq 0 ]; then
  set -- apache2-foreground
fi
exec "$@"