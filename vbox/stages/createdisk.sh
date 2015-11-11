#!/usr/bin/env sh
# This script seems to be POSIX-compliant, so using sh.

set -e # Exit on fail

# Unregister disk if it is registered.
vboxmanage list hdds | grep "$DISK" && \
  vboxmanage closemedium disk "$DISK"

# At any rate, remove it.
rm -rf "$DISK"

# And create anew.
vboxmanage createhd --filename "$DISK" --size "$DISKSIZE"
