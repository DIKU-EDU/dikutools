#!/usr/bin/env sh

set -e
set -x

rm -rf "${OVA_PATH}"

# And export the OVA.
vboxmanage export "${VERNAME}" \
  --output "${OVA_PATH}" \
  --vsys 0 \
    --product "${LONG_NAME}" \
    --description "${DESCRIPTION}" \
    --version "${VERSION}" \
    --vendor "DIKU" \
    --vendorurl "http://www.diku.dk/"
