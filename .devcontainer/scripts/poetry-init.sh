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
	echo "Unable to locate a Python project with name=\"voice-core\" under ${WORKSPACE_DIR}."
	echo "Pass the target directory explicitly: bash ${BASH_SOURCE[0]} /path/to/project"
	exit 1
fi

cd "${TARGET_DIR}"

if grep -Eq '^\[project\]' pyproject.toml; then
	if ! command -v uv >/dev/null 2>&1; then
		echo "uv not found on PATH; attempting bootstrap install..."
		if command -v pipx >/dev/null 2>&1; then
			pipx install uv >/dev/null 2>&1 || pipx upgrade uv >/dev/null 2>&1
		else
			python3 -m pip install --user uv
		fi
		export PATH="$HOME/.local/bin:${PATH}"
		if ! command -v uv >/dev/null 2>&1; then
			echo "Failed to install uv; cannot initialize PEP 621 project at ${TARGET_DIR}."
			exit 1
		fi
	fi

	# Prefer the dev dependency group when available, otherwise sync default deps.
	if grep -Eq '^\[dependency-groups\]' pyproject.toml && grep -Eq '^[[:space:]]*dev[[:space:]]*=' pyproject.toml; then
		uv sync --group dev --python 3.11
	else
		uv sync --python 3.11
	fi
elif grep -Eq '^\[tool\.poetry\]' pyproject.toml; then
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
else
	echo "No supported project metadata found in ${TARGET_DIR}/pyproject.toml."
	exit 1
fi

echo "Python environment setup complete for ${TARGET_DIR}."
