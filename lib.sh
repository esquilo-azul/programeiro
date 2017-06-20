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

function p_find_program {
  local prgname=$1
  local prgpath="$(p_path)$prgname"
  local prgbasename="$(basename "$prgpath")"
  find "$(p_path)" -path "$prgpath*" | while read line; do
    filename=$(basename "$line")
    filename="${filename%.*}"
    if [ "$filename" == "$prgbasename" ]; then
      echo "$line"
    fi
  done
}

function p_run {
  set +u
  local prgname=$1
  shift
  set -u
  if [ -z "$prgname" ]; then
    >&2 echo 'Program name not set'
    exit 3
  fi
  local prgpath="$(p_find_program "$prgname")"
  if [ -z "$prgpath" ]; then
    >&2 echo "\"$prgname\" not found"
    exit 6
  fi
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
