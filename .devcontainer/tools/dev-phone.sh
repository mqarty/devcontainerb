#!/bin/bash
# Start Twilio Dev Phone with optional phone number configuration

# Load environment from .env if it exists (in case container env vars aren't propagated)
if [ -f "$(dirname "$0")/../.env" ]; then
    set -a  # Export all variables
    source "$(dirname "$0")/../.env"
    set +a
fi

# Usage:
#   ./dev-phone.sh                           # Use phone number from TWILIO_DEV_PHONE_NUMBER env var (if set)
#   ./dev-phone.sh +15551234567              # Use specific phone number
#   ./dev-phone.sh +15551234567 --force      # Force overwrite existing webhook config
#   ./dev-phone.sh +15551234567 --headless   # Use specific phone number without opening browser

PHONE_NUMBER="${1:-$TWILIO_DEV_PHONE_NUMBER}"
EXTRA_ARGS="${@:2}"

# Add --force flag if environment variable is set
if [ "$TWILIO_DEV_PHONE_FORCE" = "true" ] || [ "$TWILIO_DEV_PHONE_FORCE" = "1" ]; then
    # Only add --force if not already in EXTRA_ARGS
    if [[ ! "$EXTRA_ARGS" =~ --force ]]; then
        EXTRA_ARGS="--force $EXTRA_ARGS"
    fi
fi

if [ -n "$PHONE_NUMBER" ]; then
    echo "🔧 Starting Twilio Dev Phone with number: $PHONE_NUMBER"
    # Show default TO number if configured
    if [ -n "$TWILIO_DEV_PHONE_TO_NUMBER" ]; then
        echo "📞 Default TO number: $TWILIO_DEV_PHONE_TO_NUMBER (configure in UI)"
    fi
    # Show if force flag is being used
    if [[ "$EXTRA_ARGS" == *"--force"* ]]; then
        echo "⚠️  Forcing overwrite of existing webhook configuration"
    fi
    # Run the command and capture exit code
    twilio dev-phone --phone-number "$PHONE_NUMBER" $EXTRA_ARGS
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ Twilio Dev Phone started successfully"
        exit 0
    else
        echo "❌ Twilio Dev Phone failed to start (exit code: $EXIT_CODE)"
        exit $EXIT_CODE
    fi
else
    echo "📱 Starting Twilio Dev Phone (no specific number configured)"
    echo "💡 Tip: Set TWILIO_DEV_PHONE_NUMBER in .env or pass as argument"
    twilio dev-phone $EXTRA_ARGS
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ Twilio Dev Phone started successfully"
        exit 0
    else
        echo "❌ Twilio Dev Phone failed to start (exit code: $EXIT_CODE)"
        exit $EXIT_CODE
    fi
fi