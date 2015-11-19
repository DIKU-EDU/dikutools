#!/usr/bin/env sh

set -e
set -x

vboxmanage startvm "${VERNAME}" --type headless

while ! vboxmanage list runningvms | grep "\"${VERNAME}\"" > /dev/null ; do 
  sleep 30
done
