#!/usr/bin/env bash
# Not sure if this is POSIX-compliant, so keep it at bash for now.

ERROR_INVALID_ARGS=1
ERROR_INVALID_CONFIG_PATH=2

function showUsage {
  cat <<EOF
Usage: $0 <config>
EOF
}

function fail {
  exit 1
}

if [ $# -lt 1 ] ; then
  showUsage
  exit $ERROR_INVALID_ARGS
fi

CONFIG="$(realpath $1)"
if [ ! -f "${CONFIG}" ] ; then
  echo "Invalid config config file path: ${CONFIG}."
  showUsage
  exit $ERROR_INVALID_CONFIG_PATH
fi

set -o allexport # All subsequent variables are exported to environment
. "${CONFIG}"
set +o allexport # Disable the above feature

./stages/exportvm.sh
