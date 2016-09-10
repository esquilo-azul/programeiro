#!/bin/bash

set -u
set -e

PRG="$0"
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

export PROOT="$(readlink -f $(dirname "$PRG"))"
source "$PROOT/lib.sh"
p_run "$@"
