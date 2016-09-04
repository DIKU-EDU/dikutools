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
patch Makefile <<EOF
3c3
< #GUIMODE=-DHAS_GUI
---
> GUIMODE=-DHAS_GUI
10c10
< TKLIBS=-L/usr/lib -ltk -ltcl
---
> TKLIBS=-L/usr/lib -ltk8.5 -ltcl8.5
EOF
make clean
make
cd ..
rm sim.tar
\""
