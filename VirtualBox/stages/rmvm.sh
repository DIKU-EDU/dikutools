#!/usr/bin/env sh

set -e
set -x

vboxmanage unregistervm "${VERNAME}" --delete
# ^^^ That should remove the disk from media manager as well.

rm -rf "${VERNAME}"
