#!/usr/bin/env bash

set -euo pipefail

GEN_ARCH=$1
MEM=512
HDA=$2
PORT=1337

qemu-system-${GEN_ARCH} \
  -monitor stdio \
  -enable-kvm \
  -display none \
  -m ${MEM} \
  -hda "${HDA}" \
  -net nic \
  -net user,hostfwd=tcp::${PORT}-:22
