#!/bin/bash

# Helper script to create .env from currently available host environment values.
# This is a convenience script; users can always edit .devcontainer/.env manually.

ENV_FILE=".devcontainer/.env"

echo "Creating $ENV_FILE from your current environment..."

# Optional: source user-specific secrets file if present.
# This keeps dotfiles optional while still supporting existing local workflows.
if [ -f "$HOME/.zshrc.secrets" ]; then
    echo "Found ~/.zshrc.secrets, sourcing it..."
    source "$HOME/.zshrc.secrets"
fi

# Create .env file
cat > "$ENV_FILE" << EOF
# Auto-generated from setup-env.sh
# Edit manually or re-run script to update

GITHUB_TOKEN=${GITHUB_TOKEN:-}
TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID:-}
TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN:-}
NGROK_AUTH_TOKEN=${NGROK_AUTH_TOKEN:-}
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
