# DevContainer Tools

Helper scripts for common development tasks.

## dev-phone.sh

Launch Twilio Dev Phone with automatic phone number configuration.

### Quick Start

```bash
# From anywhere in the workspace
.devcontainer/tools/dev-phone.sh
```

### Usage Options

**1. Use environment variables (recommended for consistent setup):**

Add to `.devcontainer/.env`:
```bash
TWILIO_DEV_PHONE_NUMBER=1555KL56893
TWILIO_DEV_PHONE_FORCE=true  # Optional: force overwrite existing webhooks
TWILIO_PHONE_TO_NUMBER=+19254306829 # The number you are testing
```

Then run:
```bash
./dev-phone.sh
```

**2. Pass phone number as argument:**
```bash
./dev-phone.sh +15551234567
```

**3. Pass phone number with additional flags:**
```bash
./dev-phone.sh +15551234567 --force         # Force overwrite webhooks
./dev-phone.sh +15551234567 --headless      # Don't open browser
./dev-phone.sh +15551234567 --port 3001     # Use custom port
./dev-phone.sh +15551234567 --clear         # Clear existing resources first
./dev-phone.sh +15551234567 --force --headless  # Combine flags
```

**4. Run without specific number:**
```bash
./dev-phone.sh
# Will use default Twilio dev-phone behavior (select from available numbers)
```

### Available Twilio Dev Phone Flags

- `--phone-number <value>` - Associates Dev Phone with a specific phone number
- `--headless` - Prevents browser from automatically opening
- `--port <value>` - Configures port for the Dev Phone UI
- `--clear` - Remove all dev-phone resources before starting
- `--force` - Forces overwrite of phone number configuration
- `-p, --profile <value>` - Use specific Twilio CLI profile

### Examples

**Always use the same number (set in .env):**
```bash
# In .devcontainer/.env
TWILIO_DEV_PHONE_NUMBER=+15551234567

# Run script
./dev-phone.sh
```

**Force overwrite existing webhook config:**
```bash
# Option 1: Set in .env (applies every time)
TWILIO_DEV_PHONE_FORCE=true

# Option 2: Pass flag on command line
./dev-phone.sh +15551234567 --force
```

**One-off with different number:**
```bash
./dev-phone.sh +15559876543
```

**Headless mode (useful for automation):**
```bash
./dev-phone.sh +15551234567 --headless
```

**Fresh start (clear previous config):**
```bash
./dev-phone.sh +15551234567 --clear
```

**Force overwrite with no browser:**
```bash
./dev-phone.sh +15551234567 --force --headless
```

## Webhook Configuration Issues

If you see an error like:
```
Cannot use +15551234567 because the following config for that phone number would be overwritten:
SMS webhook URL, Voice webhook URL
```

This means the phone number already has webhooks configured. Use `--force` to overwrite:

**Option 1: Always force (add to .env):**
```bash
TWILIO_DEV_PHONE_FORCE=true
./dev-phone.sh
```

**Option 2: Force just this once:**
```bash
./dev-phone.sh +15551234567 --force
```

**Option 3: Clear everything and start fresh:**
```bash
./dev-phone.sh +15551234567 --clear
```

## Troubleshooting

If the phone number isn't being picked up:
1. Check `.devcontainer/.env` has `TWILIO_DEV_PHONE_NUMBER` uncommented
2. Rebuild the devcontainer (environment variables loaded at container start)
3. Verify phone number format is E.164 (e.g., `+15551234567`)
4. Ensure the number is provisioned in your Twilio account

### Getting Your Twilio Phone Numbers

List available numbers:
```bash
twilio phone-numbers:list
```

Or visit: https://console.twilio.com/us1/develop/phone-numbers/manage/incoming

## aws_compose.py

Pre-auth AWS SSO and then run `docker compose`.

### Usage

```bash
# From workspace root
python .devcontainer/tools/aws_compose.py up
python .devcontainer/tools/aws_compose.py up --build
python .devcontainer/tools/aws_compose.py logs -f app

# With a different profile
AWS_PROFILE=staging python .devcontainer/tools/aws_compose.py up

# Dry run (show commands only)
python .devcontainer/tools/aws_compose.py --dry-run up --build
```

### Flags
- `--profile`, `-p` (env: AWS_PROFILE, default: dev)
- `--dry-run` (show commands, do not execute)

### Notes
- If `aws login` fails, the script exits with that code and does not run docker compose.
- Requires `typer` in the devcontainer Python env (`pip install typer`).
