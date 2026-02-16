#!/bin/bash

set -u
set -e

export PROGRAMEIRO_NOT_FOUND_ERROR=6

function p_path_expand() {
  PATH_ARG="$1"
  if [ $# -ge 2 ]; then
    BASE_ARG="$2"
  else
    BASE_ARG='/'
  fi

  if [[ "$PATH_ARG" == '/'* ]]; then
    TARGET_PATH="$(printf -- "%s\n" "$PATH_ARG")"
  else
    TARGET_PATH="$(printf -- "%s/%s\n" "$BASE_ARG" "$PATH_ARG")"
  fi

  realpath --canonicalize-missing --no-symlinks "${TARGET_PATH}"
}

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
    prgpath="$(_p_find_program_in_path "$prgname" "$path")"
    if [[ -n "$prgpath" ]]; then
      printf '%s\n' "${prgpath}"
      return
    fi
  done

  return $PROGRAMEIRO_NOT_FOUND_ERROR
}

function _p_find_program_in_path {
  local prgname=$1
  local path=$2
  local prgpath="$path""$prgname"
  local prgbasename="$(basename "$prgpath")"

  find "$path" -path "$prgpath*" | while read line; do
    filename=$(basename "$line")
    filename="${filename%.*}"
    if [ "$filename" == "$prgbasename" ]; then
      echo "$line"
      return
    fi
  done

  return $PROGRAMEIRO_NOT_FOUND_ERROR
}

function p_run {
  set +u
  local prgname=$1
  shift
  set -u
  if [ -z "${PPWD+x}" ]; then
    export PPWD='/'
  fi
  if [ -z "$prgname" ]; then
    >&2 echo 'Program name not set'
    exit 3
  fi

  local prgpath=''
  if [[ $prgname != '/'* ]] && [[ "$PPWD" != '/' ]]; then
    local prgname0="$(p_path_expand "$prgname" "$PPWD")"
    set +e
    prgpath="$(_p_run_path "$prgname0")"
    set -e
  fi

  if [[ -z "$prgpath" ]]; then
    local prgname0="$(p_path_expand "$prgname")"
    set +e
    prgpath="$(_p_run_path "$prgname0")"
    set -e
  fi

  if [[ -z "$prgpath" ]]; then
    >&2 echo "\"$prgname\" not found"
    exit 1
  fi
  PPWD="$(dirname "$prgname")" "$prgpath" "$@"
}
export -f p_run

function _p_run_path() {
  local prgname="$1"
  local prgpath="$(p_find_program "$prgname")"
  if [ -z "$prgpath" ]; then
    return $PROGRAMEIRO_NOT_FOUND_ERROR
  fi
  if [ ! -f "$prgpath" ]; then
    >&2 echo "\"$prgpath\" is not a file"
    return 4
  fi
  if [ ! -x "$prgpath" ]; then
    >&2 echo "\"$prgpath\" is not executable"
    return 5
  fi
  printf "%s\n" "$prgpath"
}

function _ends_with_slash() {
  case "$1" in
  */)
      echo 'true'
      ;;
  *)
      echo 'false'
      ;;
  esac
}

function p_completion_search() {
  p_paths | while read path; do
    p_completion_search_dir "$path" '' "$1" "$(_ends_with_slash "$1")"
  done
}
export -f p_completion_search

function p_completion_search_dir() {
  local root_dir=$1
  local subdir=$2
  local subpath=$(echo $3 | sed 's|^/\+||g' | sed 's|/\+$||g')
  local ends_with_slash=$4
  subpath_fn=$(echo "$subpath" | sed 's|/.*$||g')
  subpath_left=$(echo "$subpath" | sed 's|^[^/]*/||g')
  if [ "$subpath_left" == "$subpath" ]; then
    subpath_left=''
  fi
  find "$root_dir/$subdir" -mindepth 1 -maxdepth 1 -name "$subpath_fn*" | while read line; do
    item=$(basename "$line")
    if [ -z "$subpath_left" ]; then
      if [ -d "$line" ]; then
        if [ "$ends_with_slash" == 'true' ] && [ -n "$subpath" ]; then
          p_completion_search_dir "$root_dir" "$subdir/$item" '' "$ends_with_slash"
        else
          echo "$subdir/$item/"
        fi
      else
        echo "$subdir/${item%.*}"
      fi
    elif [ -d "$line" ]; then
      p_completion_search_dir "$root_dir" "$subdir/$item" "$subpath_left" "$ends_with_slash"
    fi
  done
}

p_paths | while read path; do
  if [ ! -d "$path" ]; then
    >&2 echo "\"$path\" in \$PPATH is not a directory"
    exit 2
  fi
done
