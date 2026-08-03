#!/usr/bin/env bash
set -euo pipefail

# One-time (or when rotating): encrypt local/secrets.json -> local/secrets.enc.json.
# secrets.json is gitignored; secrets.enc.json is safe to commit.
# Run this INSIDE the devcontainer — it needs sops + AWS creds for the
# rg-dev-sops KMS key (see local/.sops.yaml). sops discovers the .sops.yaml
# rule from secrets.json's directory automatically.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
export LOG_TAG="encrypt-secrets"

LOCAL_DIR="$(cd "${SCRIPT_DIR}/../local" && pwd)"
SECRETS_PLAIN="${LOCAL_DIR}/secrets.json"
SECRETS_ENC="${LOCAL_DIR}/secrets.enc.json"

command -v sops >/dev/null 2>&1 || {
  echo "sops not found. Run this inside the devcontainer." >&2
  exit 1
}

test -f "$SECRETS_PLAIN" || {
  echo "Missing ${SECRETS_PLAIN}." >&2
  echo "Create it from the template: cp local/secrets.json.example local/secrets.json (then fill in values)." >&2
  exit 1
}

log "Encrypting ${SECRETS_PLAIN} -> ${SECRETS_ENC}"
sops -e "$SECRETS_PLAIN" > "$SECRETS_ENC"
log "Wrote ${SECRETS_ENC} (safe to commit). You may now delete ${SECRETS_PLAIN}."
