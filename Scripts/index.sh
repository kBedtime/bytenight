#!/bin/sh
# Writes the repo's indexes (Packages, its compressed copies, Release) and depictions.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/repo.conf"
cd "$REPO"

# Keep only the newest two versions of each package and architecture.
for key in $(ls debs/*.deb 2>/dev/null | sed 's|debs/\([^_]*\)_[^_]*_\(.*\)\.deb|\1_\2|' | sort -u); do
    pkg=${key%%_*}; arch=${key#*_}
    ls debs/${pkg}_*_${arch}.deb | while read -r f; do
        echo "$(dpkg-deb -f "$f" Version) $f"
    done | sort -k1,1 -V -r | tail -n +3 | cut -d' ' -f2 | xargs rm -f
done

# dpkg-scanpackages lowercases unknown field names; clients expect SileoDepiction.
dpkg-scanpackages -m debs /dev/null 2>/dev/null | sed "s/^Sileodepiction:/SileoDepiction:/" > Packages
gzip -9nkf Packages
bzip2 -9kf Packages
xz -9kf Packages
zstd -19 -qf Packages -o Packages.zst

ARCHS=$(sed -n 's/^Architecture: //p' Packages | sort -u | tr '\n' ' ' | sed 's/ $//')
{
    echo "Origin: $ORIGIN"
    echo "Label: $LABEL"
    echo "Suite: stable"
    echo "Version: 1.0"
    echo "Codename: bytenight"
    echo "Architectures: $ARCHS"
    echo "Components: main"
    echo "Description: $DESCRIPTION"
    echo "Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')"
    echo "MD5Sum:"
    for f in Packages Packages.gz Packages.bz2 Packages.xz Packages.zst; do
        echo " $(md5 -q $f) $(stat -f %z $f) $f"
    done
    echo "SHA256:"
    for f in Packages Packages.gz Packages.bz2 Packages.xz Packages.zst; do
        echo " $(shasum -a 256 $f | cut -d' ' -f1) $(stat -f %z $f) $f"
    done
} > Release

if [ -n "${SIGNING_KEY:-}" ]; then
    rm -f InRelease Release.gpg
    gpg --batch --yes --local-user "$SIGNING_KEY" --clearsign -o InRelease Release
    gpg --batch --yes --local-user "$SIGNING_KEY" --armor --detach-sign -o Release.gpg Release
    gpg --batch --yes --export "$SIGNING_KEY" > key.gpg
fi

# Depictions: src/<id>/depiction.json with {{REPO_URL}} filled in, and a {"class": "@screenshots"}
# placeholder replaced by the images in assets/screenshots/<id> (featured themes first).
mkdir -p depictions
python3 -I "$REPO/Scripts/depiction.py" "$REPO" "$REPO_URL" "$FEATURED_THEMES"

echo "Indexed $(grep -c '^Package:' Packages) packages ($ARCHS)"
