#!/usr/bin/env bash

set -euo pipefail

CONF=$1
BASENAME="${CONF%.*}"
ORIGIN=$(pwd)

. ${CONF}

if [ "${DEB_ARCH}" = "i386" ]; then
  OSTYPE="Debian"
  BITS="32"
elif [ "${DEB_ARCH}" = "amd64" ]; then
  OSTYPE="Debian_64"
  BITS="64"
elif [ "${GEN_ARCH}" = "i386" ]; then
  OSTYPE="Linux"
  BITS="32"
elif [ "${GEN_ARCH}" = "x86_64" ]; then
  OSTYPE="Linux_64"
  BITS="64"
else
  echo "Invalid GEN_ARCH: ${GEN_ARCH}."
  exit 1
fi

VERNAME="${NAME}-${VERSION}-${BITS}-bit"

cd "${BASENAME}"
QCOW2="${BASENAME}.qcow2"
VDI="${BASENAME}.vdi"
RAW="${BASENAME}.raw"
OVA="${VERNAME}.ova"

# Delete the VirtualBox VM if it already exists.
VBoxManage unregistervm "${VERNAME}" --delete > /dev/null 2>&1 || true

rm -f "${VDI}"
qemu-img convert -O vdi "${QCOW2}" "${VDI}"

# The VDI should already be compact if the qcow2 was compressed, but try..
VBoxManage modifyhd "${VDI}" --compact

VBoxManage createvm --name "${VERNAME}" --ostype "${OSTYPE}" --register

# Create a SATA storage controller:
VBoxManage storagectl "${VERNAME}" \
  --name "SATA Controller" --add sata \
  --controller IntelAHCI --portcount 1 --bootable on

# Attach the VDI to this controller:
VBoxManage storageattach "${VERNAME}" \
  --storagectl "SATA Controller" --port 0 \
  --device 0 --type hdd --medium "${VDI}"

# Enable things like APIC shutdown:
VBoxManage modifyvm "${VERNAME}" --ioapic on
VBoxManage modifyvm "${VERNAME}" --memory ${MEM} --vram 128

# Make it user-friendly
VBoxManage modifyvm "${VERNAME}" --clipboard bidirectional
VBoxManage modifyvm "${VERNAME}" --draganddrop bidirectional

# Disable USB. Otherwise this might happen:
# https://www.virtualbox.org/ticket/14469
VBoxManage modifyvm "${VERNAME}" --mouse ps2
VBoxManage modifyvm "${VERNAME}" --usb off

# Enable SSH into the box, assuming openssh is already installed.
VBoxManage modifyvm "${VERNAME}" \
  --natpf1 "ssh,tcp,,${SSH_HOST_PORT},,22"

# Enable web-servicing from the box.
VBoxManage modifyvm "${VERNAME}" \
  --natpf1 "tcp,tcp,,${TCP_HOST_PORT},,80"

rm -f "${OVA}"
VBoxManage export "${VERNAME}" \
  --output "${OVA}" \
  --vsys 0 \
    --product "${LONG_NAME}" \
    --description "${DESCRIPTION}" \
    --version "${VERSION}" \
    --vendor "DIKU" \
    --vendorurl "http://www.diku.dk/"

# Delete the VirtualBox VM.
VBoxManage unregistervm "${VERNAME}" --delete > /dev/null 2>&1 || true
