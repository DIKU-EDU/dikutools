#!/usr/bin/env bash
# Not sure if this is POSIX-compliant, so keep it at bash for now.

ERROR_MUST_BE_ROOT=1
ERROR_INVALID_ARGS=2
ERROR_INVALID_CONFIG_PATH=3

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

if [ "$(id -u)" != "0" ]; then
  echo "For now, must be root to create VMs due to mounts."
  echo "TODO: Fix this."
  exit $ERROR_MUST_BE_ROOT
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

./stages/createvdi.sh || fail

# Enter a private mount namespace, and make sure everything is finally
# unmounted properly.
#
# See https://github.com/oleks/sandstone/blob/master/src/private-mntns.c
unshare -m bash -c "mount --make-rprivate / && ./stages/mountvdi.sh"
