#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
export LOG_TAG="post-create"

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

log "Starting post-create setup"

log "Installing dotfiles"
cd /root/dotfiles
bash install.sh
log "Dotfiles installation complete"

setup_gh_auth

POETRY_REPOS=(voice-core cohorts-api core-models)

for repo in "${POETRY_REPOS[@]}"; do
  log "Initializing Poetry environment for ${repo}"
  bash "${WORKSPACE_DIR}/.devcontainer/scripts/poetry-init.sh" "${repo}"
done

log "Initializing pre-commit hooks in background for all repos"
for repo in "${POETRY_REPOS[@]}"; do
  (
    cd "${WORKSPACE_DIR}/${repo}"
    poetry run pre-commit install
    poetry run pre-commit install-hooks
  ) >> "/tmp/pre-commit-init-${repo}.log" 2>&1 &
done
log "Pre-commit initialization running in background (tail /tmp/pre-commit-init-<repo>.log to monitor)"

log "Post-create setup complete"
