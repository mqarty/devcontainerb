# Basic Devcontainer for vscode template

## Setup

Update your *user* settings.json to include your dotfiles repo.

e.g.
```
    ...
    "dotfiles.repository": "mqarty/dotfiles",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh",
    ...
```

Then, from the command pallet run "Dev Containers: Rebuild Container"... it will take a while. Once complete you'll have your dev environment and personal settings ready to go.
