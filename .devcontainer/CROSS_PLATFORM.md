# Cross-Platform DevContainer Setup (Windows WSL2 & macOS)

This devcontainer is configured to work seamlessly 🤞 across Windows WSL2 and macOS.

## How It Works

The devcontainer runs Ubuntu 24.04 Linux in a Docker container, so the actual development environment is identical regardless of host OS. The key differences are handled automatically:

### Automatic Setup

✅ **Object paths**: Use `${localEnv:HOME}` and `${localWorkspaceFolder}` variables (OS-agnostic)  
✅ **Mounts**: SSH, history, AWS config mounted relative to your home directory  
✅ **Git config**: Handled via `mark-git-safe.sh`  
✅ **Oh My Zsh**: Auto-updates on container startup

### Oh My Zsh (Recommended)

This devcontainer is configured to use **Oh My Zsh** for an enhanced shell experience. The setup happens in two stages:

1. **Build-time (Dockerfile)**:
   - 🏗️ Oh My Zsh + plugins installed during Docker image build
   - 🔌 Plugins pre-installed:
     - `zsh-autosuggestions` - Fish-like command suggestions
     - `zsh-syntax-highlighting` - Command syntax highlighting
     - `zsh-history-substring-search` - Search history with arrow keys
   - ⚡ Faster container startup (no network dependency at startup)

2. **Post-create time (dotfiles/install.sh)**:
   - 🎨 Applies **agnoster** theme with Nerd Fonts (requires VS Code font override to "Roboto Mono for Powerline" or similar)
   - 📚 Sets up history management with auto-repair for corrupted history files (see `dotfiles/HISTORY_SETUP.md`)
   - ⚙️ Configures weekly automatic updates via Oh My Zsh
   - 🔧 Applies your personal dotfiles customizations

**Note**: The container runs `dotfiles/install.sh` automatically on first creation. Make sure your dotfiles are configured how you like them.

For manual updates or configuration after creation, use:
```bash
omz update          # Update to latest version
omz --version       # Check current version
```

### Environment-Specific Configuration

To customize per OS, edit `.devcontainer/.env`:

#### For macOS:
```bash
# .devcontainer/.env (macOS)
TZ=America/Los_Angeles
```

#### For Windows (WSL2):
```bash
# .devcontainer/.env (WSL2)
TZ=America/Chicago
```

This file is automatically loaded when the container starts via `--env-file` in `devcontainer.json`.
If you rebuild the `.devcontainer/.env` from scratch, use `setup-env.sh` (see below).

## Environment Variables and Secrets Management

### Setup (Required for devcontainer to access secrets)

For detailed instructions, see **[ENV_SETUP.md](./ENV_SETUP.md)**.

**Quick summary:**

The devcontainer loads environment variables from `.devcontainer/.env` via Docker's `--env-file` flag.

**To set up:**

1. **Quick auto-setup** (on your Mac, outside container):
   ```bash
   cd ~/Code
   .devcontainer/setup-env.sh
   ```
   This reads your existing `~/.zshrc.secrets` and creates `.devcontainer/.env`.

2. **Manual setup:**
   ```bash
   cd ~/Code/.devcontainer
   cp .env.example .env
   code .env  # Edit with your credentials
   ```

3. **Rebuild the devcontainer** (in VS Code):
   - Press `Cmd+Shift+P` (or `Ctrl+Shift+P` on Windows)
   - Search for "Dev Containers: Rebuild Container"
   - Select and run

4. **Verify:**
   ```bash
   echo $TWILIO_ACCOUNT_SID
   echo $GITHUB_TOKEN
   ```

**Note:** `.devcontainer/.env` is gitignored and will never be committed. The `.env.example` file contains only placeholders.

## Important Setup Notes

### 1. Git Line Endings (Windows WSL2)

To prevent CRLF issues on Windows, ensure your global Git config handles line endings:

```bash
# On Windows (PowerShell/CMD):
git config --global core.autocrlf true

# On macOS:
git config --global core.autocrlf input

# Or per-repo:
cd /workspaces/Code
git config core.autocrlf true  # Windows WSL2
git config core.autocrlf input # macOS
```

### 2. SSH Key Permissions (WSL2-specific)

Windows WSL2 sometimes has permission issues with SSH keys. The devcontainer handles this via `readonly` mounts, but if you get SSH permission errors:

```bash
# On Windows (in WSL2):
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
```

### 3. File Performance (WSL2-specific)

For best performance in WSL2, ensure your projects are in the WSL2 filesystem (NOT mounted from Windows):
- ✅ Good: `/home/username/projects/` 
- ❌ Slow: `/mnt/c/Users/username/projects/`

### 4. Running the Container

The setup is the same on both OSes:

```bash
# Open in VS Code (automatic)
# Or manually:
code /path/to/workspace

# Dev container will build automatically on first open
# Future opens are instant (cached)
```

## Timezone Management

The container uses the `TZ` environment variable from your host system:

- Windows (WSL2): `TZ` is automatically detected from Windows settings
- macOS: `TZ` is automatically detected from system preferences
- Override: Set `TZ` in your `.env.local` file or shell profile

Check inside container:
```bash
date
timedatectl status  # Shows current timezone
```

## Port Forwarding (SSH, Databases, etc.)

If you need to forward ports between host and container, edit `devcontainer.json`:

```json
"forwardPorts": [3000, 5432, 8000],
"portsAttributes": {
  "3000": { "label": "Application", "onAutoForward": "notify" }
}
```

## Troubleshooting

### Container rebuild needed?
```bash
# Force full rebuild
Cmd/Ctrl+Shift+P > "Dev Containers: Rebuild Container"
```

### Path issues?
The workspace is mounted at `/workspaces/Code`. Check:
```bash
ls /workspaces/Code  # Should show all your projects
pwd  # Should start with /workspaces/Code
```

### SSH not working in container?
```bash
# Check SSH socket is mounted
ls -la ~/.ssh

# Test connection
ssh -v git@github.com  # Should work if ~/.ssh/id_rsa is readable
```

## File Syncing Between Host and Container

All files in `/workspaces/Code` are automatically synced:
- Edits in VS Code container → reflected on host
- Edits on host → reflected in container
- No manual sync needed

## Summary of Changes

- ✅ Timezone set via environment variable (OS-agnostic)
- ✅ Workspace mounted at `/workspaces/Code` (single mount reduces issues)
- ✅ SSH, AWS, history mounted from `${localEnv:HOME}`
- ✅ postStartCommand uses `${containerWorkspaceFolder}` (path-agnostic)
- ✅ Read-only SSH mount prevents accidental modifications
- ✅ Container name standardized for consistency

Both WSL2 and macOS should work identically. If you hit OS-specific issues, please document them!
