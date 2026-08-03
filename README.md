# Basic Devcontainer for vscode template

## Setup

1. Set up secrets — see [Secrets](#secrets) below. In short, from `.devcontainer/`:
   `cp local/env.local.example local/env.local`, then fill in the values.
2. Update your VS Code user `settings.json` with your dotfiles repo and preferred shell.
3. Run `Dev Containers: Rebuild Container` from the command palette.

## Secrets

All secret/config files live in `.devcontainer/local/`. There's no encryption and no
committed secrets — the generated `local/.env` is merged by `build-env.sh` from two
plaintext sources (later wins on duplicate keys):
- **`env.defaults`** — shared, non-secret config (TZ, locale, history, color, flags),
  committed. Edit directly.
- **`env.local`** — **all** secrets, gitignored. Copy `env.local.example` to create it.
  It has two groups:
  - **Shared team secrets** (Twilio, Roark) — same for everyone; copy the values once
    from the team password manager (1Password, Dev vault).
  - **Personal tokens** (your GitHub / npm / ngrok / Jira / PostHog PATs) — your own.

The generated `.env` is created inside the container and never committed.

**First-time setup** (from `.devcontainer/`):
```bash
cp local/env.local.example local/env.local   # gitignored
$EDITOR local/env.local                        # fill in shared (1Password) + personal values
make build-env                                 # merge env.defaults + env.local -> local/.env
```

**Using it:** on container create/rebuild, `post-create.sh` runs `build-env.sh`, which
merges `env.defaults` + `env.local` into `local/.env`. That `.env` is loaded by the
container (`runArgs --env-file`), by in-container app builds
(`docker compose --env-file .devcontainer/local/.env ...`), and by the PostHog MCP
server (which sources it at launch). After editing `env.local`, re-run `make build-env`.

## Notes
- Shell history persists across rebuilds via a named Docker volume (`shell-history-devcontainerb`)
- History is kept separate from your host shell to prevent corruption
- In `local/`: `.env` and `env.local` are gitignored — never commit them;
  `env.defaults` and `env.local.example` are committed

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
