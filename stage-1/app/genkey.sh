#! /bin/bash
set -euo pipefail
(( UID ))
(( ! $# ))
SELF="$(readlink -f "$0")"
MYDIR="$(dirname "$SELF")"

. "$MYDIR/gpg.env"
set -vx

  #--options "$OPTIONS"   \
"$GPG"                   \
  "${ARGS[@]}"           \
  --full-gen-key "$MODE"
#  --generate-key "$MODE"
echo SUCCESS: key generated

  #--expert                   \
"$GPG"                       \
  "${ARGS[@]}"               \
  --edit-key lfs@example.com \
  trust << "EOF"
5
y
EOF
echo SUCCESS: key trusted

