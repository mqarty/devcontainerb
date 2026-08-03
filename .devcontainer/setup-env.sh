#!/bin/bash

# LEGACY FALLBACK. The canonical way to build local/.env is SOPS:
#   cd .devcontainer && make secrets && make encrypt-secrets && make build-env
# This script instead writes a minimal local/.env from your current shell env,
# for when sops/AWS aren't available. It does NOT include all secrets.

ENV_FILE=".devcontainer/local/.env"

echo "Creating $ENV_FILE from your current environment..."

# Optional: source user-specific secrets file if present.
# This keeps dotfiles optional while still supporting existing local workflows.
if [ -f "$HOME/.zshrc.secrets" ]; then
    echo "Found ~/.zshrc.secrets, sourcing it..."
    source "$HOME/.zshrc.secrets"
fi

# Create .env file
cat > "$ENV_FILE" << EOF
# Auto-generated from setup-env.sh (legacy fallback)
# Prefer 'make build-env' (SOPS). Edit manually or re-run script to update.

GITHUB_TOKEN=${GITHUB_TOKEN:-}
TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID:-}
TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN:-}
NGROK_AUTHTOKEN=${NGROK_AUTHTOKEN:-}
TZ=${TZ:-America/Los_Angeles}

# History settings (optional - already in containerEnv)
HISTFILE=/root/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
EOF

echo "✅ Created $ENV_FILE"
echo ""
echo "Please review and edit if needed:"
echo "  code $ENV_FILE"
echo ""
echo "Then rebuild your devcontainer to apply changes."
