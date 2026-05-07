#!/usr/bin/env bash

set -euo pipefail

workspace_root="${1:-}"
if [[ -z "$workspace_root" ]]; then
  echo "Usage: $0 <workspace-root>" >&2
  exit 1
fi

env_file="$workspace_root/.devcontainer/.env"
if [[ ! -f "$env_file" ]]; then
  exit 0
fi

# Read token from env file without echoing secrets.
token="$(grep -E '^GITHUB_TOKEN=' "$env_file" | head -n1 | cut -d= -f2- || true)"
token="${token%$'\r'}"
if [[ -z "$token" ]]; then
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  exit 0
fi

# Resolve GitHub username from token so docker login can authenticate to ghcr.
username="$(curl -fsSL \
  -H "Authorization: Bearer $token" \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/user \
  | sed -n 's/.*"login"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n1 || true)"

if [[ -z "$username" ]]; then
  echo "Could not resolve GitHub username from GITHUB_TOKEN; skipping ghcr login" >&2
  exit 0
fi

printf '%s' "$token" | docker login ghcr.io -u "$username" --password-stdin >/dev/null 2>&1 || true
