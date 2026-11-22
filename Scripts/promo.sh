#!/bin/sh
# Copies Lisa's promo images into assets/: the featured banners (sileo-featured.json) and the
# screenshots shown on Lisa's package page. Make them in the Lisa checkout first with
# Scripts/Promo/shoot.py and compose.py; without them this does nothing.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/repo.conf"
PROMO=$(cd "$REPO" && cd "$LISA_SRC" && pwd)/build/promo
[ -d "$PROMO/featured" ] || { echo "promo.sh: no promo images in $PROMO, skipping"; exit 0; }

mkdir -p "$REPO/assets/featured" "$REPO/assets/screenshots/com.kbedtime.lisa"
banners=""
for theme in $FEATURED_THEMES; do
    [ -f "$PROMO/featured/$theme.png" ] || { echo "promo.sh: no banner for $theme" >&2; continue; }
    cp "$PROMO/featured/$theme.png" "$REPO/assets/featured/$theme.png"
    entry=$(printf '{"url": "%s/assets/featured/%s.png", "title": "Lisa: %s", "package": "com.kbedtime.lisa", "hideShadow": true}' "$REPO_URL" "$theme" "$theme")
    banners="${banners:+$banners, }$entry"
done
printf '{"class": "FeaturedBannersView", "itemSize": "{300, 203}", "itemCornerRadius": 10, "banners": [%s]}\n' "$banners" > "$REPO/sileo-featured.json"

# Every theme's light/dark pair, featured themes first, for the package page.
rm -f "$REPO/assets/screenshots/com.kbedtime.lisa/"*.png
for f in "$PROMO/pairs/"*.png; do cp "$f" "$REPO/assets/screenshots/com.kbedtime.lisa/"; done
echo "Promo: featured $FEATURED_THEMES; $(ls "$REPO/assets/screenshots/com.kbedtime.lisa" | wc -l | tr -d ' ') screenshots"
