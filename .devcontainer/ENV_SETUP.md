# Environment Variable Setup for Devcontainer

## Problem
Environment variables defined in your Mac's shell (`.zshrc.secrets`) are not available to VS Code's GUI process, so `${localEnv:...}` in devcontainer.json returns empty values.

## Solution: Use .env File (Recommended)

### Quick Setup

**On your Mac (outside the devcontainer):**

```bash
cd ~/Code  # or wherever your workspace is
.devcontainer/setup-env.sh
```

This will read your existing environment (including `~/.zshrc.secrets`) and create `.devcontainer/.env`.

**Manual Setup:**

```bash
cd ~/Code/.devcontainer
cp .env.example .env
# Edit .env and add your actual values
code .env
```

Then **rebuild your devcontainer** for changes to take effect.

### How It Works

The devcontainer now uses `--env-file` to load environment variables from `.devcontainer/.env`:

- ✅ Works reliably (not dependent on how VS Code was launched)
- ✅ File is gitignored (won't commit secrets)
- ✅ Easy to update (just edit the file and rebuild)
- ✅ Portable (works on Mac, Linux, Windows)

## Alternative Solutions

### Option 2: Use ~/.zshenv on Mac

If you want `${localEnv:...}` to work, move your environment variables to `~/.zshenv` on your Mac:

```bash
# On your Mac
echo 'export TWILIO_ACCOUNT_SID="your_value"' >> ~/.zshenv
echo 'export TWILIO_AUTH_TOKEN="your_value"' >> ~/.zshenv
# ... etc
```

Then **launch VS Code from terminal**:
```bash
code ~/Code
```

⚠️ This only works if VS Code inherits the environment, which is unreliable with GUI launches.

### Option 3: Launch VS Code from Terminal Always

```bash
# On your Mac
cd ~/Code
source ~/.zshrc.secrets  # Load your secrets
code .                   # Launch VS Code with current environment
```

⚠️ Must remember to do this every time.

## Recommended Approach

**Use the .env file** (Solution 1). It's the most reliable and portable approach.

## Verifying It Works

After rebuilding your devcontainer:

```bash
echo $TWILIO_ACCOUNT_SID
echo $GITHUB_TOKEN
```

Should now show your values! 🎉
