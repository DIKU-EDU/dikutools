#!/usr/bin/env bash

set -euo pipefail

GEN_ARCH=x86_64
MEM=512
HDA=$1

qemu-system-${GEN_ARCH} \
  -enable-kvm \
  -display none \
  -m ${MEM} \
  -hda "${HDA}" \
  -net nic \
  -net user,hostfwd=tcp::1337-:22
