#! /bin/bash
set -euo pipefail
(( UID ))
(( $# ))
. /etc/profile
for k in "$@" ; do
  case "$k" in
    cert)    MODE=$CA-cert    /app/genkey.sh ;;
    sign)    MODE=$SA-sign    /app/addkey.sh ;;
    encrypt) MODE=$EA-encrypt /app/addkey.sh ;;
    auth)    MODE=$AA-auth    /app/addkey.sh ;;
    *)       exit 1                          ;;
  esac
done

