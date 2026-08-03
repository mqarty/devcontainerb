#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
export LOG_TAG="post-create"

WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

VSCODE_EXTENSIONS=(
  ms-python.python
  charliermarsh.ruff
  github.copilot-chat
  streetsidesoftware.code-spell-checker
  postman.postman-for-vscode
  ms-toolsai.jupyter
)

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

install_vscode_extensions() {
  local code_cli=""
  if command -v code-insiders >/dev/null 2>&1; then
    code_cli="$(command -v code-insiders)"
  elif command -v code >/dev/null 2>&1; then
    code_cli="$(command -v code)"
  fi

  if [[ -z "${code_cli}" ]]; then
    log "Skipping VS Code extension install retry (code CLI not found)"
    return
  fi

  log "Retrying VS Code extension installation"
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if "${code_cli}" --install-extension "${ext}" --pre-release --force >/dev/null 2>&1; then
      log "Installed extension (pre-release): ${ext}"
      continue
    fi

    if "${code_cli}" --install-extension "${ext}" --force >/dev/null 2>&1; then
      log "Installed extension (stable fallback): ${ext}"
    else
      log "Extension install skipped/failed (non-blocking): ${ext}"
    fi
  done
}

log "Starting post-create setup"

log "Installing dotfiles"
cd /root/dotfiles
bash install.sh
log "Dotfiles installation complete"

if command -v zsh >/dev/null 2>&1; then
  current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  zsh_path="$(command -v zsh)"
  if [[ "${current_shell}" != "${zsh_path}" ]]; then
    log "Setting default login shell to zsh"
    chsh -s "${zsh_path}" "$(id -un)" || true
  fi
fi

setup_gh_auth
install_vscode_extensions

PYTHON_ENV_REPOS=(voice-core)

for repo in "${PYTHON_ENV_REPOS[@]}"; do
  log "Initializing Python environment (uv/poetry auto-detect) for ${repo}"
  bash "${WORKSPACE_DIR}/.devcontainer/scripts/poetry-init.sh" "${repo}"
done

# log "Initializing pre-commit hooks in background for all repos"
# for repo in "${PYTHON_ENV_REPOS[@]}"; do
#   (
#     cd "${WORKSPACE_DIR}/${repo}"
#     uv run pre-commit install
#     uv run pre-commit install-hooks
#   ) >> "/tmp/pre-commit-init-${repo}.log" 2>&1 &
# done
# log "Pre-commit initialization running in background (tail /tmp/pre-commit-init-<repo>.log to monitor)"

log "Post-create setup complete"
