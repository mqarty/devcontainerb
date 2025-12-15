#!/usr/bin/env bash
set -euo pipefail

# Find mounted git repositories under /workspaces and mark them safe for global git
# This is invoked from devcontainer's postStartCommand so mounts are available.

ROOT_DIR="/workspaces"

if [ ! -d "$ROOT_DIR" ]; then
  echo "No $ROOT_DIR directory found, skipping git safe marking."
  exit 0
fi

find "$ROOT_DIR" -type d -name .git -print 2>/dev/null | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  echo "Marking safe.directory: $repo_dir"
  git -C "$repo_dir" config --global --add safe.directory "$repo_dir" || true
done

echo "Done marking git safe directories."
