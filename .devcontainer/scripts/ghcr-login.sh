#!/usr/bin/env bash

set -euo pipefail

log() {
  echo "[ghcr-login] $*"
}

workspace_root="${1:-}"
if [[ -z "$workspace_root" ]]; then
  echo "Usage: $0 <workspace-root>" >&2
  exit 1
fi

log "Attempting to authenticate to ghcr.io"

env_file="$workspace_root/.devcontainer/.env"
if [[ ! -f "$env_file" ]]; then
  log "No .env file found; skipping ghcr login"
  exit 0
fi

# Read token from env file without echoing secrets.
token="$(grep -E '^GITHUB_TOKEN=' "$env_file" | head -n1 | cut -d= -f2- || true)"
token="${token%$'\r'}"
if [[ -z "$token" ]]; then
  log "No GITHUB_TOKEN in .env; skipping ghcr login"
  exit 0
fi

log "Found GITHUB_TOKEN, checking for docker"
if ! command -v docker >/dev/null 2>&1; then
  log "docker not found on PATH; skipping ghcr login"
  exit 0
fi

log "Resolving GitHub username from token"
# Resolve GitHub username from token so docker login can authenticate to ghcr.
username="$(curl -fsSL \
  -H "Authorization: Bearer $token" \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/user \
  | sed -n 's/.*"login"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n1 || true)"

if [[ -z "$username" ]]; then
  echo "Could not resolve GitHub username from GITHUB_TOKEN; skipping ghcr login" >&2
  log "Failed to resolve username; skipping ghcr login"
  exit 0
fi

log "Logging into ghcr.io as $username"
printf '%s' "$token" | docker login ghcr.io -u "$username" --password-stdin >/dev/null 2>&1 || true
log "ghcr.io login complete"
