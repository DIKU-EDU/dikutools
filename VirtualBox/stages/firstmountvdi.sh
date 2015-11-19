#!/usr/bin/env sh
# This script seems to be POSIX-compliant, so using sh.

set -e # Exit on fail

mkdir -p "$VDI_MNTPNT"
./vdfuse -f "$VDI_PATH" "$VDI_MNTPNT"
