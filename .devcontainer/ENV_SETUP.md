# Environment Variable Setup for Devcontainer

## Canonical Approach

Use `.devcontainer/.env` as the shared, supported source for devcontainer secrets.

Do not rely on shell startup files (such as dotfiles) for required project credentials.
Dotfiles remain user-specific and optional.

## Why This Is The Default

- Works when VS Code is launched from GUI or terminal.
- Keeps a single project-level setup path for all users.
- Supports Docker Compose build secrets that depend on `GITHUB_TOKEN`.
- `.devcontainer/.env` is ignored by git.

## Required Variables

At minimum for private GitHub dependencies:

- `GITHUB_TOKEN`

Common additional variables:

- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `NGROK_AUTH_TOKEN`
- `TZ`

## Setup Steps

### Option A (recommended): manual `.devcontainer/.env`

```bash
cd /path/to/workspace/.devcontainer
cp .env.example .env
code .env
```

Set at least:

```dotenv
GITHUB_TOKEN=your_github_pat_here
```

Then rebuild the devcontainer.

### Option B: bootstrap from your current host environment

```bash
cd /path/to/workspace
.devcontainer/setup-env.sh
```

This script can read values already exported in your current shell. If present, it also sources `~/.zshrc.secrets` to help prefill values.

## Docker Compose Notes

When running `docker compose` inside the devcontainer, the compose secret mapping `environment: GITHUB_TOKEN` reads from the current process environment.

Because devcontainer startup uses `.devcontainer/.env`, `GITHUB_TOKEN` is available in the container shell and can be forwarded to compose build secrets.

For compose files that also rely on a service env file (for example `voice-core/.env.local`), include it at runtime:

```bash
cd /workspaces/Code/voice-core
docker compose --env-file .env.local -f docker-compose.local.yml up -d --build --force-recreate
```

`--env-file .env.local` configures application variables. `GITHUB_TOKEN` still comes from the shell environment unless explicitly overridden.

## Verification

After rebuilding the devcontainer:

```bash
echo "GITHUB_TOKEN length: ${#GITHUB_TOKEN}"
```

From `voice-core`:

```bash
docker compose --env-file .env.local -f docker-compose.local.yml config | grep -A3 GITHUB_TOKEN
```

If token access still fails during build, confirm PAT permissions and SSO authorization for the target organization repositories.
