#!/bin/bash

set -u
set -e

function p_path {
  set +u
  r=$PPATH
  set -u
  if [ -n "$r" ]; then
    r=$(readlink -f "$r")
  fi
  echo "$r"
}

function p_run {
  set +u
  prgname=$1
  shift
  set -u
  if [ -z "$prgname" ]; then
    >&2 echo 'Program name not set'
    exit 3
  fi
  prgpath="$(p_path)$prgname"
  if [ ! -f "$prgpath" ]; then
    >&2 echo "\"$prgpath\" is not a file"
    exit 4
  fi
  if [ ! -x "$prgpath" ]; then
    >&2 echo "\"$prgpath\" is not executable"
    exit 5
  fi
  "$prgpath" "$@"
}
export -f p_run

if [ -z "$(p_path)" ]; then
  >&2 echo '$PPATH is empty'
  exit 1
fi

if [ ! -d "$(p_path)" ]; then
  >&2 echo "\$PPATH=\"$PPATH\" is not a directory"
  exit 2
fi
