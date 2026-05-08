# Basic Devcontainer for vscode template

## Setup

1. Copy the env file and fill in your credentials:
```bash
   cp .devcontainer/.env.example .devcontainer/.env
```
2. Update your VS Code user `settings.json` with your dotfiles repo and preferred shell.
3. Run `Dev Containers: Rebuild Container` from the command palette.

## Notes
- Shell history persists across rebuilds via a named Docker volume (`shell-history-devcontainerb`)
- History is kept separate from your host shell to prevent corruption
- `.env` is gitignored — never commit it

Update your *user* settings.json to include your dotfiles repo and terminal preferences.

e.g.
```
    ...
    "dotfiles.repository": "mqarty/dotfiles",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh",
    "terminal.integrated.defaultProfile.linux": "zsh",
    "terminal.integrated.profiles.linux": {
        "zsh": {
            "path": "zsh"
        }
    },
    ...
```

Then, from the command pallet run "Dev Containers: Rebuild Container"... it will take a while. Once complete you'll have your dev environment and personal settings ready to go.
