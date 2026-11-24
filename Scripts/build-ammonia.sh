#!/bin/sh
# Wraps the newest Ammonia release's ammonia.pkg in a dpkg package, one per architecture.
# The version is the release tag plus src/net.bedtime.ammonia/revision (bump that only
# when these wrapper scripts change for the same Ammonia release).
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/repo.conf"
PACKAGE=net.bedtime.ammonia
SRC="$REPO/src/$PACKAGE"

TAG=$(gh release view -R "$AMMONIA_GITHUB" --json tagName -q .tagName)
VERSION="${TAG#v}-$(cat "$SRC/revision")"
CACHE="$REPO/.cache/ammonia/$TAG"
[ -f "$CACHE/ammonia.pkg" ] || gh release download "$TAG" -R "$AMMONIA_GITHUB" -p ammonia.pkg -D "$CACHE"
pkgutil --check-signature "$CACHE/ammonia.pkg" >/dev/null 2>&1 || true   # Ammonia's releases are unsigned

for ARCH in darwin-arm64 darwin-amd64; do
    OUT="$REPO/debs/${PACKAGE}_${VERSION}_${ARCH}.deb"
    rm -f "$OUT"
    STAGE=$(mktemp -d)
    chmod 755 "$STAGE"
    mkdir -p "$STAGE/DEBIAN" "$STAGE/Library/bytenight"
    cp "$CACHE/ammonia.pkg" "$STAGE/Library/bytenight/ammonia.pkg"
    chmod 644 "$STAGE/Library/bytenight/ammonia.pkg"
    cp "$SRC/postinst" "$SRC/prerm" "$SRC/postrm" "$STAGE/DEBIAN/"
    chmod 755 "$STAGE/DEBIAN/"*
    {
        echo "Package: $PACKAGE"
        echo "Name: Ammonia"
        echo "Version: $VERSION"
        echo "Architecture: $ARCH"
        echo "Maintainer: kBedtime"
        echo "Author: MachLiberation"
        echo "Section: System"
        echo "Installed-Size: $(du -sk "$STAGE" | cut -f1)"
        echo "Depends: cy+os.macosx"
        echo "Homepage: https://github.com/$AMMONIA_GITHUB"
        echo "Description: Tweak loader for macOS"
        echo "SIPOffRequired: yes"
        if [ -n "$REPO_URL" ]; then
            echo "SileoDepiction: $REPO_URL/depictions/$PACKAGE.json"
        fi
    } > "$STAGE/DEBIAN/control"
    chmod 644 "$STAGE/DEBIAN/control"
    COPYFILE_DISABLE=1 dpkg-deb -Zxz --root-owner-group -b "$STAGE" "$OUT" >/dev/null
    rm -rf "$STAGE"
    echo "$OUT"
done
