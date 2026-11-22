#!/bin/sh
# Builds Lisa from its checkout and copies the package here.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/repo.conf"
SRC=$(cd "$REPO" && cd "$LISA_SRC" && pwd)
ICON=""
[ -n "$REPO_URL" ] && [ -f "$REPO/assets/com.kbedtime.lisa/icon.png" ] && ICON="$REPO_URL/assets/com.kbedtime.lisa/icon.png"
DEB=$(REPO_URL="$REPO_URL" ICON_URL="$ICON" "$SRC/Scripts/BuildDeb.sh" | tail -1)
cp "$DEB" "$REPO/debs/"
echo "$REPO/debs/$(basename "$DEB")"
