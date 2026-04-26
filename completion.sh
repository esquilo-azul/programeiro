#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
export PROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if [[ -z $PALIAS ]]; then
  PALIAS="programeiro"
fi
FUNCTION_NAME="_p_completion_$PALIAS"

_p_completion() {
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  case "$COMP_CWORD" in
    1)
    COMPREPLY=( $( p_completion_search $cur ) )
    ;;

    *)
    COMPREPLY=( $( compgen -o default -- $cur ) )
    ;;
  esac
  return 0
}

eval "${FUNCTION_NAME}() { source '$PROOT/lib.sh'; set +u; set +e; _p_completion; return 0; }"
complete -F "$FUNCTION_NAME" -o nospace "$PALIAS"
