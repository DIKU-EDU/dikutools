#!/usr/bin/env bash

set -euo pipefail

set +x

ISO_PATH=$1
PRESEED_PATH=$2

OUT_PATH="${ISO_PATH%.*}-preseeded.iso"

# Following guide: https://wiki.debian.org/DebianInstaller/Preseed/EditIso
# But doing things without need to be root.

mkdir loopdir
fuseiso "${ISO_PATH}" loopdir
mkdir cd
rsync -a -H --exclude=TRANS.TBL loopdir/ cd
fusermount -u loopdir

chmod +w cd -R

gunzip cd/install.amd/initrd.gz
cp "${PRESEED_PATH}" .
chmod +r preseed.cfg
chmod +w preseed.cfg
chmod +x preseed.cfg
echo -n "preseed.cfg" | cpio -o -H newc -A -F cd/install.amd/initrd
cpio -ivt -H newc < cd/install.amd/initrd
gzip cd/install.amd/initrd
rm preseed.cfg

$(cd cd && md5sum `find -follow -type f` > md5sum.txt)

genisoimage -o ${OUT_PATH} -r -J -no-emul-boot -boot-load-size 4 \
  -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ./cd
