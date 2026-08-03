# Devcontainer secrets tooling (SOPS). Thin wrappers over scripts/*.sh.
# Run INSIDE the devcontainer — needs sops + AWS creds for the rg-dev-sops KMS key.
# Secret/config files live in local/; scripts live in scripts/.
#
#   make secrets          # create local/secrets.json from the template (if missing)
#   make encrypt-secrets  # local/secrets.json -> local/secrets.enc.json (commit the .enc.json)
#   make build-env        # local/secrets.enc.json -> local/.env (decrypt)

.PHONY: help secrets encrypt-secrets build-env

# Absolute path to this Makefile's directory, so targets work from anywhere.
MK_DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
LOCAL_DIR := $(MK_DIR)/local

help:
	@echo "Devcontainer secrets (SOPS) — run inside the devcontainer:"
	@echo "  make secrets          Create local/secrets.json from secrets.json.example (if missing)"
	@echo "  make encrypt-secrets  Encrypt local/secrets.json -> local/secrets.enc.json (commit this)"
	@echo "  make build-env        Decrypt local/secrets.enc.json -> local/.env"

secrets:
	@if [ -f "$(LOCAL_DIR)/secrets.json" ]; then \
		echo "local/secrets.json already exists — leaving it untouched."; \
	else \
		cp "$(LOCAL_DIR)/secrets.json.example" "$(LOCAL_DIR)/secrets.json"; \
		echo "Created local/secrets.json from template. Fill in real values, then 'make encrypt-secrets'."; \
	fi

encrypt-secrets:
	"$(MK_DIR)/scripts/encrypt-secrets.sh"

build-env:
	"$(MK_DIR)/scripts/build-env.sh"
