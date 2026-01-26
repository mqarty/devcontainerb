# DevContainer-specific bash/zsh aliases
# This file is sourced during devcontainer startup

# Twilio Dev Phone
alias dev-phone='/workspaces/Code/.devcontainer/tools/dev-phone.sh'
alias devphone='/workspaces/Code/.devcontainer/tools/dev-phone.sh'

# Quick navigation
alias devcontainer='cd /workspaces/Code/.devcontainer'
alias dotfiles='cd /workspaces/Code/dotfiles'
alias voice='cd /workspaces/Code/voice-core'
alias pulse='cd /workspaces/Code/pulse'

# Docker shortcuts (container management from inside devcontainer)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlogs='docker logs -f'

# AWS pre-auth wrapper for docker compose
alias aws-compose='python /workspaces/Code/.devcontainer/tools/aws_compose.py'
alias dcu='aws-compose up'

# Twilio CLI shortcuts
alias twilio-list-numbers='twilio phone-numbers:list'
alias twilio-profiles='twilio profiles:list'
