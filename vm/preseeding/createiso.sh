#!/usr/bin/env bash

set -euo pipefail

CONF=$1
BASENAME="${CONF%.*}"
ORIGIN=$(pwd)

. ${CONF}

./tmpdir --cwd --prefix preseed \
  "${ORIGIN}/preseediso.sh" "${ORIGIN}/${ISO_RELPATH}" "${ORIGIN}/preseed.cfg"
