#!/usr/bin/env bash
set -euo pipefail

# Find mounted git repositories under /workspaces and mark them safe for global git
# This is invoked from devcontainer's postStartCommand so mounts are available.

ROOT_DIR="/workspaces"

if [ ! -d "$ROOT_DIR" ]; then
  echo "No $ROOT_DIR directory found, skipping git safe marking."
  exit 0
fi

timeout 10 find "$ROOT_DIR" -maxdepth 3 -type d -name .git -print 2>/dev/null | while IFS= read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  git config --global --add safe.directory "$repo_dir" 2>/dev/null || true
done || true

echo "Done marking git safe directories."
