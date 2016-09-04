#!/usr/bin/env bash

set -euo pipefail

CONF=$1
BASENAME="${CONF%.*}"
ORIGIN=$(pwd)

. ${CONF}

mkdir -p "${BASENAME}"
cd "${BASENAME}"
rm -rf *

HDA="${BASENAME}.qcow2"
qemu-img create -f qcow2 "${HDA}" 5G

qemu-system-${GEN_ARCH} \
  -enable-kvm \
  -monitor stdio \
  -m ${MEM} \
  -net nic \
  -net user \
  -boot d \
  -cdrom "${ORIGIN}/${ISO_RELPATH}" \
  -drive file="${HDA}",index=0,media=disk,format=qcow2
