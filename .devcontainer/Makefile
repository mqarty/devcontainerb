# Devcontainer env tooling. Thin wrapper over scripts/build-env.sh.
# Run INSIDE the devcontainer. No secrets are encrypted or committed:
# secrets live in local/env.local (gitignored); shared team values come from
# the team password manager. Config/template files live in local/.
#
#   cp local/env.local.example local/env.local   # then fill in values
#   make build-env                                # env.defaults + env.local -> local/.env

.PHONY: help build-env

# Absolute path to this Makefile's directory, so targets work from anywhere.
MK_DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
LOCAL_DIR := $(MK_DIR)/local

help:
	@echo "Devcontainer env — run inside the devcontainer:"
	@echo "  make build-env   Merge env.defaults + env.local -> local/.env"
	@echo ""
	@echo "First-time setup: cp local/env.local.example local/env.local, then fill it in."

build-env:
	"$(MK_DIR)/scripts/build-env.sh"
