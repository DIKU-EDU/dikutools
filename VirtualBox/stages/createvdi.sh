#!/usr/bin/env sh
# This script seems to be POSIX-compliant, so using sh.

set -e # Exit on fail

VDI_PATH="$(realpath "$VDI_PATH")"

# Unregister disk if it is registered.
vboxmanage list hdds | grep "$VDI_PATH" && \
  vboxmanage closemedium disk "$VDI_PATH"

# At any rate, remove it.
rm -rf "$VDI_PATH"

# And create anew.
vboxmanage createhd --filename "$VDI_PATH" --size "$VDI_SIZE"
