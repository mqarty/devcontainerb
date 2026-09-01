#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
export LOG_TAG="post-create"

WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

setup_gh_auth() {
  log "Configuring GitHub CLI authentication"
  if command -v gh >/dev/null 2>&1 && [[ -n "${GITHUB_TOKEN:-}" ]]; then
    timeout 10 bash -c "printf '%s' \"${GITHUB_TOKEN}\" | gh auth login --hostname github.com --with-token >/dev/null 2>&1" || log "GitHub CLI auth login timed out"
    timeout 10 gh auth setup-git >/dev/null 2>&1 || log "GitHub CLI setup-git timed out"
    log "GitHub CLI authentication configured"
  else
    log "Skipping GitHub CLI authentication (gh or GITHUB_TOKEN missing)"
  fi

  # Some networks block SSH (port 22), which breaks git/uv fetches over an
  # unconditional insteadOf rewrite. Only prefer SSH if it's actually reachable;
  # otherwise keep HTTPS, which gh auth setup-git already wired up with a token.
  if timeout 5 ssh -T -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 git@github.com >/dev/null 2>&1; [[ $? -eq 1 ]]; then
    log "Configuring git to use SSH for GitHub"
    git config --global url."git@github.com:".insteadOf "https://github.com/" || true
  else
    log "SSH to github.com unavailable; keeping HTTPS for GitHub URLs"
    git config --global --unset url."git@github.com:".insteadOf 2>/dev/null || true
  fi
}

mark_repos_safe() {
  # Workspace repos are owned by the host user, not root, so git refuses to use them.
  log "Marking workspace repositories as git safe directories"

  # Find all repos with .git and collect them
  local repos
  mapfile -t repos < <(find "${WORKSPACE_DIR}" -maxdepth 2 -type d -name .git -exec dirname {} \; | sort -u)

  if [[ ${#repos[@]} -eq 0 ]]; then
    log "No git repositories found"
    return
  fi

  # Get existing safe directories once
  local existing_safe
  existing_safe="$(git config --global --get-all safe.directory 2>/dev/null | sort -u || true)"

  # Add each repo if not already present
  for repo in "${repos[@]}"; do
    if ! grep -Fxq "$repo" <<<"$existing_safe"; then
      git config --global --add safe.directory "$repo"
    fi
  done
}

install_pre_commit_hooks() {
  log "Installing pre-commit hooks for repositories with pre-commit configuration"

  # Find all repos with .pre-commit-config.yaml
  local repos
  mapfile -t repos < <(find "${WORKSPACE_DIR}" -maxdepth 2 -name .pre-commit-config.yaml -type f -exec dirname {} \; | sort -u)

  if [[ ${#repos[@]} -eq 0 ]]; then
    log "No pre-commit configurations found"
    return
  fi

  for repo in "${repos[@]}"; do
    log "Installing pre-commit hook in ${repo##*/}"
    (cd "$repo" && timeout 30 pre-commit install) || log "WARNING: pre-commit install failed in ${repo##*/}"
  done
}

log "Starting post-create setup"

log "Installing dotfiles"
cd /root/dotfiles
bash install.sh
log "Dotfiles installation complete"

log "Assembling .env from env.defaults + env.local"
bash "${WORKSPACE_DIR}/.devcontainer/scripts/build-env.sh" || true
# Load the assembled secrets so the steps below (gh auth, uv) see GITHUB_TOKEN
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
mark_repos_safe
install_pre_commit_hooks

UV_SYNC_REPOS=(voice-core)

for repo in "${UV_SYNC_REPOS[@]}"; do
  log "Syncing uv dependencies for ${repo}"
  bash "${WORKSPACE_DIR}/.devcontainer/scripts/uv-sync.sh" "${repo}"
done

log "Post-create setup complete"
