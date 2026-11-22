#!/bin/sh
# One step from a Lisa commit to the live repo: rebuild what changed, re-index, sign,
# commit and push. GitHub Pages serves the result a minute or so later.
#   Scripts/publish.sh ["what changed"]
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
"$REPO/Scripts/update.sh"
cd "$REPO"
git add -A
if git diff --cached --quiet; then
    echo "Nothing changed; the live repo is up to date."
    exit 0
fi
. "$REPO/repo.conf"
git commit -q -m "${1:-Update packages}" -m "$(sed -n 's/^Package: //p;s/^Version: /  /p' Packages | paste - - | sort -u)"
git push -q
echo "Published to $REPO_URL"
