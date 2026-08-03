# Basic Devcontainer for vscode template

## Setup

1. Set up secrets — see [Secrets (SOPS)](#secrets-sops) below. In short, from
   `.devcontainer/` inside the container: `make secrets`, fill in the values, then
   `make encrypt-secrets`.
2. Update your VS Code user `settings.json` with your dotfiles repo and preferred shell.
3. Run `Dev Containers: Rebuild Container` from the command palette.

## Secrets (SOPS)

All secret/config files live in `.devcontainer/local/`. Secrets are stored encrypted
with [SOPS](https://github.com/getsops/sops) using the `rg-dev-sops` AWS KMS key (see
`local/.sops.yaml`). The generated `local/.env` has three sources, merged by
`build-env.sh` (later wins on duplicate keys):
- **`env.defaults`** — shared non-secret config (TZ, locale, history, color, flags),
  committed in plaintext. Edit directly.
- **`secrets.enc.json`** — credentials, SOPS-encrypted (committed).
- **`env.local`** — personal per-developer overrides (your phone numbers, ngrok
  domain, or any value you don't want in git). Gitignored; copy `env.local.example`
  to create it. Applied last, so it overrides the other two.

The decrypted `.env` is generated inside the container and never committed.

Because AWS/KMS access lives inside the devcontainer (not on the host), all `sops`
commands run **inside** the container. A `Makefile` in `.devcontainer/` wraps the
tooling (`make help` to list targets).

**First-time / rotating secrets** (from `.devcontainer/`):
```bash
make secrets                 # cp local/secrets.json.example -> local/secrets.json (gitignored)
$EDITOR local/secrets.json   # fill in real values
make encrypt-secrets         # -> local/secrets.enc.json (safe to commit)
make build-env               # decrypt + merge -> local/.env (verify it works; optional)
rm local/secrets.json        # optional; keep only the encrypted file
git add .devcontainer/local/secrets.enc.json && git commit
```
The scripts under `scripts/` (`encrypt-secrets.sh`, `build-env.sh`) do the actual
work; the Makefile targets are thin wrappers, so either interface works.

**Using them:** on container create/rebuild, `post-create.sh` runs `build-env.sh`,
which decrypts `local/secrets.enc.json` into `local/.env`. That `.env` is loaded by
the container (`runArgs --env-file`), by in-container app builds
(`docker compose --env-file .devcontainer/local/.env ...`), and by the PostHog MCP
server (which sources it at launch). To refresh by hand after editing secrets, re-run
`make encrypt-secrets` then `make build-env`.

## Notes
- Shell history persists across rebuilds via a named Docker volume (`shell-history-devcontainerb`)
- History is kept separate from your host shell to prevent corruption
- In `local/`: `.env`, `secrets.json`, and `env.local` are gitignored — never commit them;
  `secrets.enc.json`, `env.defaults`, `env.local.example`, `secrets.json.example`, and
  `.sops.yaml` are committed

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
