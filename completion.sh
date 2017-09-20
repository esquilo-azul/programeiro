#!/bin/bash

P_ALIAS="programeiro"
FUNCTION_NAME="_p_completion_$P_ALIAS"

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
complete -F "$FUNCTION_NAME" -o nospace "$P_ALIAS"
