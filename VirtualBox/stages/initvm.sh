#!/usr/bin/env bash
# This script is probably not POSIX-compliant, so using bash.

set -e
set -x

# Check that the original VM actually exists
vboxmanage showvminfo "$BASE" &> /dev/null

set -o allexport
VERNAME="${NAME}-v${VERSION}"
OVA_PATH="${NAME}-v${VERSION}.ova"
FULL_PATH="${VERNAME}/${VERNAME}"
VDI_PATH="${FULL_PATH}.vdi"
set +o allexport

# Shut down the new VM if it already exists and is running:
if vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; then
  ./stages/spindownvm.sh
fi

# Delete the VM if it already exists:
vboxmanage unregistervm "${VERNAME}" --delete &>/dev/null || true

# Prepare a local folder (using tmp might not work, you need much space).
mkdir -p "${VERNAME}"
rm -rf "${VERNAME}/*"


CFG_PATH=$(vboxmanage showvminfo "$BASE" | grep "Config file" | \
  sed -E 's/Config file:\s*(.*?)$/\1/')
HD_UUID=$(cat "${CFG_PATH}" | grep "HardDisk uuid" | \
  sed -E 's/.*uuid="\{(.*?)\}".*/\1/')


# Remove the disk from the VirtualBox media registry, if it is there.
vboxmanage closemedium "${VDI_PATH}" --delete &>/dev/null || true

# Clone the HD to something we can later compact:
vboxmanage clonehd "${HD_UUID}" "${VDI_PATH}" --format VDI

# Create a new VM with the version number:
vboxmanage createvm --name "${VERNAME}" --ostype "Debian_64" --register

# Create a SATA storage controller:
vboxmanage storagectl "${VERNAME}" \
  --name "SATA Controller" --add sata \
  --controller IntelAHCI --portcount 1 --bootable on

# Attach the VDI to this controller:
vboxmanage storageattach "${VERNAME}" \
  --storagectl "SATA Controller" --port 0 \
  --device 0 --type hdd --medium "${VDI_PATH}"

# Enable things like APIC shutdown:
vboxmanage modifyvm "${VERNAME}" --ioapic on
vboxmanage modifyvm "${VERNAME}" --memory 512 --vram 128

# Make it user-friendly
vboxmanage modifyvm "${VERNAME}" --clipboard bidirectional
vboxmanage modifyvm "${VERNAME}" --draganddrop bidirectional

# Disable USB. Otherwise this might happen:
# https://www.virtualbox.org/ticket/14469
vboxmanage modifyvm "${VERNAME}" --mouse ps2
vboxmanage modifyvm "${VERNAME}" --usb off

# Enable SSH into the box, assuming openssh is already installed.
VBoxManage modifyvm "${VERNAME}" \
  --natpf1 "ssh,tcp,,${SSH_HOST_PORT},,22"
