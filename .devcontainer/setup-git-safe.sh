#!/bin/sh
set -e
# Ensure git is configured with safe settings
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global --add safe.directory /workspaces/b6n/notebooks
git config --global --add safe.directory /workspaces/b6n/devcontainerb
