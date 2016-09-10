#!/bin/bash

set -u
set -e

if [ "$#" -lt 1 ]; then
  >&2 echo "Usage: $0 <PPATH>"
  exit 1
fi

RC_FILE="$HOME/.config/programeiro/bashrc"
mkdir -p "`dirname "$RC_FILE"`"

cat <<EOF > "$RC_FILE"
export PPATH=$1
alias programeiro="$PROOT/run.sh"
EOF

LINE=". '$RC_FILE'"
if ! grep -q "$LINE" ~/.bashrc; then
    echo "$LINE" >> ~/.bashrc
fi

>&2 echo "Line "$LINE" added to ~/.bashrc"
>&2 echo "\"$RC_FILE\"'s content:"
>&2 cat "$RC_FILE"
