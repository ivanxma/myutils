#!/bin/bash
set -euo pipefail

FORCE="${FORCE:-0}"

usage() {
  cat <<EOF >&2
Usage: $0 <service-name> <runscript> <user>

Creates /etc/systemd/system/<service-name>.service with ExecStart set to
<runscript> and User set to <user>, then runs systemctl daemon-reload.

Set FORCE=1 to replace an existing unit file.
EOF
}

if [[ $# -ne 3 ]]; then
  usage
  exit 1
fi

SERVICE_NAME="$1"
RUNSCRIPT_INPUT="$2"
RUN_AS_USER="$3"

if [[ "$SERVICE_NAME" =~ [[:space:]/] ]]; then
  echo "Invalid service name: $SERVICE_NAME" >&2
  echo "Service names must not contain spaces or '/' characters." >&2
  exit 1
fi

if [[ "$SERVICE_NAME" != *.service ]]; then
  UNIT_NAME="${SERVICE_NAME}.service"
else
  UNIT_NAME="$SERVICE_NAME"
  SERVICE_NAME="${SERVICE_NAME%.service}"
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl is required but was not found in PATH." >&2
  exit 1
fi

if ! id "$RUN_AS_USER" >/dev/null 2>&1; then
  echo "User not found: $RUN_AS_USER" >&2
  exit 1
fi

if [[ "$RUNSCRIPT_INPUT" != /* ]]; then
  RUNSCRIPT_PATH="$(cd "$(dirname "$RUNSCRIPT_INPUT")" && pwd)/$(basename "$RUNSCRIPT_INPUT")"
else
  RUNSCRIPT_PATH="$RUNSCRIPT_INPUT"
fi

if [[ ! -f "$RUNSCRIPT_PATH" ]]; then
  echo "Run script not found: $RUNSCRIPT_PATH" >&2
  exit 1
fi

if [[ ! -x "$RUNSCRIPT_PATH" ]]; then
  echo "Run script is not executable: $RUNSCRIPT_PATH" >&2
  exit 1
fi

WORKING_DIR="$(dirname "$RUNSCRIPT_PATH")"
UNIT_PATH="/etc/systemd/system/$UNIT_NAME"

if [[ -e "$UNIT_PATH" && "$FORCE" != "1" ]]; then
  echo "Unit file already exists: $UNIT_PATH" >&2
  echo "Set FORCE=1 to replace it." >&2
  exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
  AS_ROOT=()
elif command -v sudo >/dev/null 2>&1; then
  AS_ROOT=(sudo)
else
  echo "This script must run as root or with sudo available." >&2
  exit 1
fi

"${AS_ROOT[@]}" tee "$UNIT_PATH" >/dev/null <<EOF
[Unit]
Description=$SERVICE_NAME service
After=network.target

[Service]
Type=simple
User=$RUN_AS_USER
WorkingDirectory=$WORKING_DIR
ExecStart=$RUNSCRIPT_PATH
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

"${AS_ROOT[@]}" chmod 644 "$UNIT_PATH"
"${AS_ROOT[@]}" systemctl daemon-reload

cat <<EOF
Created systemd unit: $UNIT_PATH

To enable at boot:
  sudo systemctl enable $UNIT_NAME

To start now:
  sudo systemctl start $UNIT_NAME

To check status:
  systemctl status $UNIT_NAME
EOF
