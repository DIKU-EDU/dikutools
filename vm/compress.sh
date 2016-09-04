#!/usr/bin/env bash

set -euo pipefail

CONF=$1
BASENAME="${CONF%.*}"
ORIGIN=$(pwd)

. ${CONF}

cd "${BASENAME}"
HDA="${BASENAME}.qcow2"

mv "${HDA}" "${HDA}_backup"
qemu-img convert -O qcow2 -c "${HDA}_backup" "${HDA}"
