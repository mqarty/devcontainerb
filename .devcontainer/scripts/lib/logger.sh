#!/usr/bin/env bash

# Shared logging utility for devcontainer startup scripts.
# Source this file in any script that needs the log() function.
# Usage: source /path/to/logger.sh

log() {
  local tag="${LOG_TAG:-devcontainer}"
  echo "[$tag] $*"
}
