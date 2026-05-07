#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

setup_gh_auth() {
  if command -v gh >/dev/null 2>&1 && [[ -n "${GITHUB_TOKEN:-}" ]]; then
    printf '%s' "${GITHUB_TOKEN}" | gh auth login --hostname github.com --with-token >/dev/null 2>&1 || true
    gh auth setup-git >/dev/null 2>&1 || true
  fi
}

ensure_aliases_source() {
  local rc_file="$1"
  local source_line="source ${WORKSPACE_DIR}/.devcontainer/aliases.sh"

  touch "$rc_file"
  if ! grep -qF "$source_line" "$rc_file"; then
    echo "$source_line" >> "$rc_file"
  fi
}

bash "${WORKSPACE_DIR}/.devcontainer/scripts/mark-git-safe.sh"

setup_gh_auth

ensure_aliases_source "$HOME/.zshrc"
ensure_aliases_source "$HOME/.bashrc"
