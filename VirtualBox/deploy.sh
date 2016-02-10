#!/usr/bin/env sh

set -e # exit on error

if [ $# -ne 2 ]; then
  echo "Usage: $0 <user> <file>"
  exit 1
fi

set -x # show commands as they execute

OPTIONS=(--progress --compress --update --chmod=+r)

rsync ${OPTIONS[@]} "$2" "$1@napoleon.hiperfit.dk:/home/$1/public_html/$2"
rsync ${OPTIONS[@]} "$2" "$1@harlem.dikurevy.dk:/home/$1/public_html/$2"
