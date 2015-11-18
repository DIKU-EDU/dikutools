#!/usr/bin/env bash
# This script is probably not POSIX-compliant, so using bash.

set -e
set -x

# Check that the original VM actually exists
vboxmanage showvminfo "$NAME" &> /dev/null

VERNAME="${NAME}-v${VERSION}"
OVA_PATH="${NAME}-v${VERSION}.ova"

# Shut down the new VM if it already exists and is running:
if vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; then
  vboxmanage controlvm "${VERNAME}" acpipowerbutton

  while vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; do 
    sleep 30
  done
fi

# Delete the VM if it already exists:
vboxmanage unregistervm "${VERNAME}" --delete &>/dev/null || true

# Prepare a local folder (using tmp might not work, you need much space).
mkdir -p "${VERNAME}"
rm -rf "${VERNAME}/*"

FULL_PATH="${VERNAME}/${VERNAME}"

CFG_PATH=$(vboxmanage showvminfo "$NAME" | grep "Config file" | \
  sed -E 's/Config file:\s*(.*?)$/\1/')
HD_UUID=$(cat "${CFG_PATH}" | grep "HardDisk uuid" | \
  sed -E 's/.*uuid="\{(.*?)\}".*/\1/')

VDI_PATH="${FULL_PATH}.vdi"

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

# Disable USB. Otherwise this might happen:
# https://www.virtualbox.org/ticket/14469
vboxmanage modifyvm "${VERNAME}" --mouse ps2
vboxmanage modifyvm "${VERNAME}" --usb off

# Enable SSH into the box, assuming openssh is already installed.
VBoxManage modifyvm "${VERNAME}" \
  --natpf1 "ssh,tcp,,${SSH_HOST_PORT},,22"

# Start the VM and scrub it!
vboxmanage startvm "${VERNAME}" --type headless

while ! vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; do 
  sleep 30
done

sshpass -p "${PASSWD}" ssh -p ${SSH_HOST_PORT} \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  root@localhost "bash -c \"
adduser \"${USER}\" vboxsf

rm -rf /var/cache/apt/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/log/dpkg.log*
rm -rf /home/archimedes/.*_history

rm -rf /usr/lib/x86_64-linux-gnu-gallium-pipe
rm -rf /usr/lib/x86_64-linux-gnu/dri

dd if=/dev/zero of=/tmp/zero bs=1M
rm /tmp/zero
shutdown -h now
\""

# Shut down the VM
vboxmanage controlvm "${VERNAME}" acpipowerbutton

while vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; do 
  sleep 30
done

# Finally, compact the disk after the clean up:
vboxmanage modifyhd "${VDI_PATH}" --compact

rm -rf "${OVA_PATH}"

# And export the OVA.
vboxmanage export "${VERNAME}" \
  --output "${OVA_PATH}" \
  --vsys 0 \
    --product "${LONG_NAME}" \
    --description "${DESCRIPTION}" \
    --version "${VERSION}" \
    --vendor "DIKU" \
    --vendorurl "http://www.diku.dk/"

# Clean up
vboxmanage unregistervm "${VERNAME}" --delete
# ^^^ That should delete the disk from media manager as well.
rm -rf "${VERNAME}"
