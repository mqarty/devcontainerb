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

cd /root/dotfiles
bash install.sh

setup_gh_auth

bash "${WORKSPACE_DIR}/.devcontainer/scripts/poetry-init.sh" voice-core
