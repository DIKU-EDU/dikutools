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
apt-get update
apt-get -y install git xorg build-essential gdb qemu bochs nginx \\
  flex bison tcl-dev tk-dev
cat <<EOF | tr '%' '\\$' > /etc/nginx/sites-available/public_html
server {
  listen 80;
  listen [::]:80;

  server_name localhost;

  index index.html;

  location ~ \\\"^/~([a-z]{3}[0-9]{3})(/.*?)?$\\\" {
    alias /home/%1/public_html/%2;
    autoindex on;
  }
}
EOF
cd /etc/nginx/sites-enabled/
rm -f public_html
ln -s ../sites-available/public_html public_html
service nginx restart
su archimedes -c \\\"mkdir /home/archimedes/public_html\\\"
\""
