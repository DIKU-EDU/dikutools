#!/usr/bin/env bash

set -euo pipefail

CONF=$1
BASENAME="${CONF%.*}"
ORIGIN=$(pwd)

. ${CONF}

ISO_RELPATH="${ISO_RELPATH%.*}-preseeded.iso"

mkdir -p "${BASENAME}"
cd "${BASENAME}"
rm -rf *

HDA="${BASENAME}.img"
qemu-img create "${HDA}" 5G

qemu-system-${GEN_ARCH} \
  -monitor stdio \
  -m ${MEM} \
  -net nic \
  -net user \
  -boot d \
  -cdrom "${ORIGIN}/${ISO_RELPATH}" \
  -drive file="${HDA}",index=0,media=disk,format=raw
