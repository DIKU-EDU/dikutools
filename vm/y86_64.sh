#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sshpass

set -euo pipefail

PORT=1337

sshpass -p "hamster" ssh \
  -p ${PORT} \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o LogLevel=ERROR \
  archimedes@localhost "bash -c \"
rm -rf sim
wget -N http://csapp.cs.cmu.edu/3e/sim.tar
tar xvf sim.tar
cd sim
make clean
make
cd ..
rm sim.tar
\""
