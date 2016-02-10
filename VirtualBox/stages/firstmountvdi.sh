#!/usr/bin/env sh
# This script seems to be POSIX-compliant, so using sh.

set -e # Exit on fail

mount | grep -q "MNTPNT" && sudo umount -l "$MNTPNT"
sleep 0.1
mount | grep -q "$VDI_MNTPNT" && sudo umount -l "$VDI_MNTPNT"
rm -rf "$MNTPNT" "$VDI_MNTPNT"

mkdir -p "$VDI_MNTPNT"
./vdfuse -f "$VDI_PATH" "$VDI_MNTPNT"

mke2fs -L "$NAME" -t ext2 "$VDI_MNTPNT/EntireDisk"

mkdir -p "$MNTPNT"
mount "$VDI_MNTPNT/EntireDisk" "$MNTPNT"

$@
