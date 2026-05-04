#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TARGET_DIR="${1:-}"

# Resolve relative paths against the workspace root
if [[ -n "${TARGET_DIR}" && "${TARGET_DIR}" != /* ]]; then
	TARGET_DIR="${WORKSPACE_DIR}/${TARGET_DIR}"
fi

if [[ -z "${TARGET_DIR}" ]]; then
	mapfile -t PYPROJECT_FILES < <(find "${WORKSPACE_DIR}" -mindepth 2 -maxdepth 3 -type f -name pyproject.toml)
	for pyproject_file in "${PYPROJECT_FILES[@]}"; do
		if grep -Eq '^[[:space:]]*name[[:space:]]*=[[:space:]]*"voice-core"' "${pyproject_file}"; then
			TARGET_DIR="$(dirname "${pyproject_file}")"
			break
		fi
	done
fi

if [[ -z "${TARGET_DIR}" ]]; then
	echo "Unable to locate a Poetry project with name=\"voice-core\" under ${WORKSPACE_DIR}."
	echo "Pass the target directory explicitly: bash ${BASH_SOURCE[0]} /path/to/project"
	exit 1
fi

cd "${TARGET_DIR}"

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PATH="${PYENV_ROOT}/bin:${PATH}"

if command -v pyenv >/dev/null 2>&1; then
	eval "$(pyenv init -)"
	pyenv install -s 3.11
else
	echo "pyenv not found on PATH. Please install pyenv before running this script."
	exit 1
fi

poetry env use 3.11

poetry install

echo "Environment setup complete for ${TARGET_DIR}."
