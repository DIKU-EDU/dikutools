#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sshpass

set -euo pipefail

PORT=1337

sshpass -p "hamster2" ssh \
  -p ${PORT} \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o LogLevel=ERROR \
  root@localhost "bash -c \"
shutdown -h now
\""
