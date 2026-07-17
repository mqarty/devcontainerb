#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
export LOG_TAG="post-start"

WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

setup_gh_auth() {
  log "Configuring GitHub CLI authentication"
  if command -v gh >/dev/null 2>&1 && [[ -n "${GITHUB_TOKEN:-}" ]]; then
    printf '%s' "${GITHUB_TOKEN}" | gh auth login --hostname github.com --with-token >/dev/null 2>&1 || true
    gh auth setup-git >/dev/null 2>&1 || true
    log "GitHub CLI authentication configured"
  else
    log "Skipping GitHub CLI authentication (gh or GITHUB_TOKEN missing)"
  fi
}

ensure_aliases_source() {
  local rc_file="$1"
  local source_line="source ${WORKSPACE_DIR}/.devcontainer/aliases.sh"

  touch "$rc_file"
  if ! grep -qF "$source_line" "$rc_file"; then
    echo "$source_line" >> "$rc_file"
    log "Added aliases source line to $rc_file"
  else
    log "Aliases source line already present in $rc_file"
  fi
}

log "Starting post-start setup"

log "Marking git repositories as safe"
bash "${WORKSPACE_DIR}/.devcontainer/scripts/mark-git-safe.sh"
log "Git safe.directory setup complete"

setup_gh_auth

log "Authenticating to ghcr.io"
bash "${WORKSPACE_DIR}/.devcontainer/scripts/ghcr-login.sh" "${WORKSPACE_DIR}"

ensure_aliases_source "$HOME/.zshrc"
ensure_aliases_source "$HOME/.bashrc"

log "Post-start setup complete"
