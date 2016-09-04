#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sshpass

set -euo pipefail

MESSAGE=$1
PORT=1337

sshpass -p "hamster2" ssh \
  -p ${PORT} \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o LogLevel=ERROR \
  root@localhost "bash -c \"
apt-get update
apt-get -y install toilet
echo $MESSAGE | toilet > /etc/motd
apt-get -y remove --auto-remove toilet
\""
