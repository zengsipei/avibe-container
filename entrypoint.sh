#!/usr/bin/env bash
set -euo pipefail

UPDATE_AI_CLI="${UPDATE_AI_CLI:-true}"
UPDATE_AVIBE="${UPDATE_AVIBE:-true}"
START_AVIBE="${START_AVIBE:-true}"
AVIBE_INSTALL_URL="${AVIBE_INSTALL_URL:-https://avibe.bot/install.sh}"
AVIBE_LOG="${AVIBE_LOG:-$HOME/.avibe/avibe.log}"

echo "Initializing avibe container environment..."

if [ "$UPDATE_AI_CLI" = "true" ]; then
  echo "Installing or updating AI CLI tools..."
  npm install -g @anthropic-ai/claude-code@latest
fi

if command -v vibe >/dev/null 2>&1; then
  if [ "$UPDATE_AVIBE" = "true" ]; then
    echo "Updating avibe..."
    vibe upgrade
  fi
else
  echo "Installing avibe..."
  curl -fsSL "$AVIBE_INSTALL_URL" | bash
fi

for profile in "$HOME/.bashrc" "$HOME/.profile"; do
  if [ -f "$profile" ]; then
    # Installers often append PATH changes to shell profiles.
    # shellcheck disable=SC1090
    . "$profile" || true
  fi
done

for bin_dir in "$HOME/.avibe/bin" "$HOME/.local/bin" "$HOME/bin"; do
  if [ -x "$bin_dir/vibe" ]; then
    export PATH="$bin_dir:$PATH"
    break
  fi
done

if ! command -v vibe >/dev/null 2>&1; then
  echo "vibe command was not found after installation." >&2
  exit 1
fi

if [ "$START_AVIBE" = "true" ]; then
  mkdir -p "$(dirname "$AVIBE_LOG")"
  echo "Starting avibe in the background. Logs: $AVIBE_LOG"
  vibe >>"$AVIBE_LOG" 2>&1 &
  echo "$!" > /tmp/avibe.pid
else
  echo "Skipping avibe background start because START_AVIBE=$START_AVIBE."
fi

echo "Development environment ready."
exec "$@"
