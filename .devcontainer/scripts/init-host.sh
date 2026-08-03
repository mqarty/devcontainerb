#!/usr/bin/env bash
# Runs on the HOST (macOS or WSL) via devcontainer.json "initializeCommand",
# BEFORE the container is created. Its only job: guarantee the env-file that
# runArgs `--env-file` references exists, so `docker run --env-file` doesn't
# abort on a fresh checkout. post-create.sh (inside the container) later fills
# it in by decrypting secrets.enc.json.
#
# Keep this resilient and dependency-free: a non-zero exit here aborts the whole
# container "up". On WSL a prior container run (as root) can leave local/ or
# .env root-owned, and the host user then can't touch it. We can't sudo from
# here, so we surface the exact fix instead of a cryptic `touch: Permission
# denied`. Docker Desktop for macOS remaps ownership, so this path rarely trips
# there.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/local"
ENV_FILE="${LOCAL_DIR}/.env"

mkdir -p "${LOCAL_DIR}" 2>/dev/null || true

# Already present (the common rebuild case) — nothing to do. Note: --env-file is
# read by the Docker daemon (root), so the file need not be readable by the host
# user; it only needs to exist.
if [[ -e "${ENV_FILE}" ]]; then
  exit 0
fi

if touch "${ENV_FILE}" 2>/dev/null; then
  exit 0
fi

cat >&2 <<EOF
init-host: cannot create ${ENV_FILE}
  A previous container run (as root) likely left this file's directory
  root-owned. This is common on WSL, where bind mounts preserve real UIDs
  (Docker Desktop for macOS masks it). Fix it on the host, then retry:

    sudo chown -R "\$(id -un):\$(id -gn)" "${LOCAL_DIR}"
EOF
exit 1
