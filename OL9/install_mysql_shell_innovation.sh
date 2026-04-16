#!/bin/bash
set -euo pipefail

REPO_RPM_URL="https://repo.mysql.com/mysql84-community-release-el9.rpm"
DISABLE_REPOS=(
  mysql-8.4-lts-community
  mysql-tools-8.4-lts-community
  mysql80-community
  mysql-tools-community
)
ENABLE_REPOS=(
  mysql-innovation-community
  mysql-tools-innovation-community
)

if ! command -v dnf >/dev/null 2>&1; then
  echo "dnf is required but was not found in PATH." >&2
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  OS_MAJOR="${VERSION_ID%%.*}"
else
  echo "Unable to determine operating system version from /etc/os-release." >&2
  exit 1
fi

if [[ "${OS_MAJOR:-}" != "9" ]]; then
  echo "This installer is for Oracle Linux 9. Detected VERSION_ID=${VERSION_ID:-unknown}." >&2
  exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
  AS_ROOT=()
else
  AS_ROOT=(sudo)
fi

repo_exists() {
  local repo_id="$1"
  dnf repolist all 2>/dev/null | grep -qE "^${repo_id}[[:space:]]"
}

set_repo_state() {
  local state_flag="$1"
  local repo_id="$2"

  if repo_exists "$repo_id"; then
    "${AS_ROOT[@]}" dnf config-manager "$state_flag" "$repo_id"
  fi
}

"${AS_ROOT[@]}" dnf -y install dnf-plugins-core
"${AS_ROOT[@]}" dnf -y install "$REPO_RPM_URL"

for repo_id in "${DISABLE_REPOS[@]}"; do
  set_repo_state --set-disabled "$repo_id"
done

for repo_id in "${ENABLE_REPOS[@]}"; do
  set_repo_state --set-enabled "$repo_id"
done

"${AS_ROOT[@]}" dnf clean all
"${AS_ROOT[@]}" dnf -y install mysql-shell

echo
echo "Installed mysql-shell from the MySQL Innovation repository on Oracle Linux 9."
echo "Enabled MySQL repos:"
dnf repolist enabled | grep mysql || true
