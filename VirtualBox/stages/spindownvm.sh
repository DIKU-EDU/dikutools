#!/usr/bin/env sh

set -e
set -x

vboxmanage controlvm "${VERNAME}" acpipowerbutton

while vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; do 
  sleep 30
done
