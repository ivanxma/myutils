#!/bin/bash
set -euo pipefail

PORT_INPUT="${1:-443}"

if [[ "$PORT_INPUT" == */* ]]; then
  PORT_RULE="$PORT_INPUT"
else
  PORT_RULE="$PORT_INPUT/tcp"
fi

PORT_NUMBER="${PORT_RULE%/*}"
PORT_PROTO="${PORT_RULE#*/}"

if ! [[ "$PORT_NUMBER" =~ ^[0-9]+$ ]] || (( PORT_NUMBER < 1 || PORT_NUMBER > 65535 )); then
  echo "Invalid port: $PORT_NUMBER" >&2
  echo "Usage: $0 [port|port/protocol]" >&2
  exit 1
fi

if [[ "$PORT_PROTO" != "tcp" && "$PORT_PROTO" != "udp" ]]; then
  echo "Invalid protocol: $PORT_PROTO" >&2
  echo "Supported protocols: tcp, udp" >&2
  exit 1
fi

if ! command -v firewall-cmd >/dev/null 2>&1; then
  echo "firewall-cmd is required but was not found in PATH." >&2
  exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
  FIREWALL_CMD=(firewall-cmd)
elif command -v sudo >/dev/null 2>&1; then
  FIREWALL_CMD=(sudo firewall-cmd)
else
  echo "This script must run as root or with sudo available." >&2
  exit 1
fi

if "${FIREWALL_CMD[@]}" --permanent --zone=public --query-port="$PORT_RULE" >/dev/null; then
  echo "Port already enabled in public zone: $PORT_RULE"
else
  "${FIREWALL_CMD[@]}" --permanent --zone=public --add-port="$PORT_RULE"
  echo "Enabled port in public zone: $PORT_RULE"
fi

"${FIREWALL_CMD[@]}" --reload
echo "Firewall reloaded."
