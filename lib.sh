#!/bin/bash

set -u
set -e

function p_paths {
  set +u
  local paths=$PPATH
  set -u
  local OIFS=$IFS
  IFS=':'
  for path in $paths; do
    readlink -f "$path"
  done
  IFS=$OIFS
  echo "$PROOT/programs"
}

function p_find_program {
  local prgname=$1
  p_paths | while read path; do
    local prgpath="$path""$prgname"
    local prgbasename="$(basename "$prgpath")"
    find "$path" -path "$prgpath*" | while read line; do
      filename=$(basename "$line")
      filename="${filename%.*}"
      if [ "$filename" == "$prgbasename" ]; then
        echo "$line"
      fi
    done
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

p_paths | while read path; do
  if [ ! -d "$path" ]; then
    >&2 echo "\"$path\" in \$PPATH is not a directory"
    exit 2
  fi
done
