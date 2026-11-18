#!/bin/sh
# Clean installation only. Never modifies an existing 3x-ui installation.
set -eu
PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
BASE=https://github.com/larmaxval-cpu/3x-ui-keenetic-arm64
VERSION=v3.11.0-keenetic.1
EXPECTED=1876676d3b26a8869c527d2e99fc38475eb9ad1a75ff9bcd04b97601bd90a998
DIR=/opt/etc/x-ui
TMP=
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup() { [ -z "$TMP" ] || rm -rf "$TMP"; }
trap cleanup EXIT HUP INT TERM
[ "$(id -u)" = 0 ] || fail 'Run as root'
[ "$(uname -m)" = aarch64 ] || fail 'Only aarch64 supported'
[ -d /opt/etc ] && command -v opkg >/dev/null 2>&1 || fail 'Entware required'
[ ! -e "$DIR" ] && [ ! -L "$DIR" ] || fail 'Existing x-ui directory found; no changes made'
[ ! -e /opt/etc/init.d/S99x-ui ] && [ ! -L /opt/etc/init.d/S99x-ui ] || fail 'Existing service found; no changes made'
[ ! -e /opt/bin/x-ui ] && [ ! -L /opt/bin/x-ui ] || fail 'Existing x-ui command found; no changes made'
# Required packages, including the shell used by the known Keenetic management script.
opkg update
opkg install bash curl libcurl ca-bundle ca-certificates unzip coreutils coreutils-sha256sum || fail 'Cannot install dependencies'
for cmd in curl sha256sum unzip bash; do command -v "$cmd" >/dev/null 2>&1 || fail "Missing $cmd"; done
mkdir -p /opt/tmp
TMP=$(mktemp -d /opt/tmp/xui-install.XXXXXX) || fail 'Cannot create temp dir'
printf 'Downloading patched 3x-ui...\n'
curl -fL --retry 2 -o "$TMP/xui" "$BASE/releases/download/$VERSION/xui-linux-arm64" || fail '3x-ui download failed'
ACTUAL=$(sha256sum "$TMP/xui" | awk '{print $1}')
[ "$ACTUAL" = "$EXPECTED" ] || fail '3x-ui SHA256 mismatch'
# The management script must be included in this repository and reviewed before publishing.
curl -fL --retry 2 -o "$TMP/x-ui.sh" "$BASE/raw/refs/heads/main/x-ui.sh" || fail 'x-ui.sh not published in repository'
[ -s "$TMP/x-ui.sh" ] || fail 'Empty x-ui.sh'
head -n 1 "$TMP/x-ui.sh" | grep -q '^#!/opt/bin/bash' || fail 'Unexpected management script'
printf 'Downloading Xray v26.10.21...\n'
curl -fL --retry 2 -o "$TMP/xray.zip" 'https://github.com/XTLS/Xray-core/releases/download/v26.10.21/Xray-linux-arm64-v8a.zip' || fail 'Xray download failed; check release asset name'
mkdir -p "$TMP/xray"
unzip -q "$TMP/xray.zip" -d "$TMP/xray" || fail 'Cannot extract Xray'
[ -s "$TMP/xray/xray" ] || fail 'Xray binary missing from archive'
for f in geoip.dat geosite.dat; do
  if [ ! -s "$TMP/xray/$f" ]; then
    case "$f" in
      geoip.dat) url='https://github.com/v2fly/geoip/releases/latest/download/geoip.dat' ;;
      geosite.dat) url='https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat' ;;
    esac
    curl -fL --retry 2 -o "$TMP/xray/$f" "$url" || fail "Cannot download $f"
  fi
done
# Do not create the application directory until all required downloads are complete.
mkdir -p "$DIR/bin" "$DIR/db" "$DIR/cache" "$DIR/config"
install -m 755 "$TMP/xui" "$DIR/xui"
install -m 755 "$TMP/x-ui.sh" "$DIR/x-ui.sh"
install -m 755 "$TMP/xray/xray" "$DIR/bin/xray-linux-arm64"
install -m 644 "$TMP/xray/geoip.dat" "$DIR/bin/geoip.dat"
install -m 644 "$TMP/xray/geosite.dat" "$DIR/bin/geosite.dat"
ln -s "$DIR/x-ui.sh" /opt/etc/init.d/S99x-ui
ln -s "$DIR/x-ui.sh" /opt/bin/x-ui
printf '\nFiles installed. Initial panel settings and service startup have NOT been validated.\n'
printf 'Review configuration and run: /opt/etc/init.d/S99x-ui start\n'
