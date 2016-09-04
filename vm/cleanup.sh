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
rm -rf /var/cache/apt/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/log/dpkg.log*
rm -rf /home/archimedes/.*_history

rm -rf /usr/lib/x86_64-linux-gnu-gallium-pipe
rm -rf /usr/lib/x86_64-linux-gnu/dri

dd if=/dev/zero of=zero bs=1M
rm zero
shutdown -h now
\""
