#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="$SCRIPT_DIR/.cert"
CERT_FILE="$CERT_DIR/selfsigned.crt"
KEY_FILE="$CERT_DIR/selfsigned.key"
DAYS="${DAYS:-365}"
CN="${CN:-localhost}"
FORCE="${FORCE:-0}"
VERBOSE="${VERBOSE:-0}"

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required but was not found in PATH." >&2
  exit 1
fi

mkdir -p "$CERT_DIR"

if [[ "$FORCE" != "1" && ( -f "$CERT_FILE" || -f "$KEY_FILE" ) ]]; then
  echo "Certificate already exists. Set FORCE=1 to recreate it." >&2
  echo "crt: $CERT_FILE"
  echo "key: $KEY_FILE"
  exit 0
fi

OPENSSL_ARGS=(
  req -x509 -nodes -newkey rsa:2048 -days "$DAYS"
  -keyout "$KEY_FILE"
  -out "$CERT_FILE"
  -subj "/CN=$CN"
)

if [[ "$VERBOSE" == "1" ]]; then
  openssl "${OPENSSL_ARGS[@]}"
else
  openssl "${OPENSSL_ARGS[@]}" >/dev/null 2>&1
fi

chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

cat <<EOF
Self-signed certificate created.

crt: $CERT_FILE
key: $KEY_FILE
CN:  $CN
EOF
