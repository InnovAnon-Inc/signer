#! /bin/bash
set -euo pipefail
(( UID ))
(( ! $# ))
SELF="$(readlink -f "$0")"
MYDIR="$(dirname "$SELF")"

. "$MYDIR/gpg.env"
set -vx

"$GPG"                       \
  "${ARGS[@]}"               \
  --edit-key lfs@example.com < "$MODE"

set +vx
OUT="/tmp/$(basename "$MODE")"
case "$(basename "$MODE")" in
  *-sign.*)
    trap "rm -fv $OUT" 0
    set -vx
    "$GPG" "${ARGS[@]}" --sign -o "$OUT.gpg" "$MODE"
    "$GPG" "${ARGS[@]}" --verify  "$OUT.gpg"
    echo SUCCESS: signing and verification
    ;;
  *-encrypt.*)
    trap "rm -fv $OUT" 0
    set -vx
    "$GPG" "${ARGS[@]}" --encrypt --recipient lfs@example.com -o "$OUT.gpg" "$MODE"
    "$GPG" "${ARGS[@]}" --decrypt                             -o "$OUT"     "$OUT.gpg"
    diff -q "$MODE" "$OUT" # || { cat "$OUT" ; exit 2 ; }
    echo SUCCESS: encryption and decryption
    ;;
  *-auth.*)
    echo TODO: authentication ;;
  *-cert.*)
    echo TODO: certification  ;;
  *) exit 1 ;;
esac

