#!/bin/sh
# Rebuilds every package that changed and re-indexes the repo. Run after any Lisa commit
# or Ammonia release; it's safe to run any time.
set -eu
DIR=$(cd "$(dirname "$0")" && pwd)
"$DIR/build-ammonia.sh"
"$DIR/build-lisa.sh"
"$DIR/promo.sh"
"$DIR/index.sh"
