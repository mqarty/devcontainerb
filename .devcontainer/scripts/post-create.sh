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

  # Configure git to use SSH for GitHub URLs (private repo access, no terminal prompt needed)
  log "Configuring git to use SSH for GitHub"
  git config --global url."git@github.com:".insteadOf "https://github.com/" || true
}

install_pre_commit_hooks() {
  log "Installing pre-commit hooks for repositories with pre-commit configuration"
  for repo in "${WORKSPACE_DIR}"/*; do
    if [[ -d "${repo}/.git" && -f "${repo}/.pre-commit-config.yaml" ]]; then
      log "Installing pre-commit hook in ${repo##*/}"
      (cd "${repo}" && pre-commit install)
    fi
  done
}

log "Starting post-create setup"

log "Installing dotfiles"
cd /root/dotfiles
bash install.sh
log "Dotfiles installation complete"

log "Assembling .env from env.defaults + env.local"
bash "${WORKSPACE_DIR}/.devcontainer/scripts/build-env.sh" || true
# Load the assembled secrets so the steps below (gh auth, poetry) see GITHUB_TOKEN
# even on first creation, when runArgs --env-file read an empty .env.
if [[ -f "${WORKSPACE_DIR}/.devcontainer/local/.env" ]]; then
  set -a; source "${WORKSPACE_DIR}/.devcontainer/local/.env"; set +a
  log "Loaded ${WORKSPACE_DIR}/.devcontainer/local/.env into environment"
fi

if command -v zsh >/dev/null 2>&1; then
  current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  zsh_path="$(command -v zsh)"
  if [[ "${current_shell}" != "${zsh_path}" ]]; then
    log "Setting default login shell to zsh"
    chsh -s "${zsh_path}" "$(id -un)" || true
  fi
fi

setup_gh_auth
install_pre_commit_hooks

PYTHON_ENV_REPOS=(voice-core)

for repo in "${PYTHON_ENV_REPOS[@]}"; do
  log "Initializing Python environment (uv/poetry auto-detect) for ${repo}"
  bash "${WORKSPACE_DIR}/.devcontainer/scripts/poetry-init.sh" "${repo}"
done

log "Post-create setup complete"
