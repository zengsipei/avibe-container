#!/usr/bin/env bash
set -euo pipefail

UPDATE_AI_CLI="${UPDATE_AI_CLI:-true}"
UPDATE_AVIBE="${UPDATE_AVIBE:-true}"
START_AVIBE="${START_AVIBE:-true}"
AVIBE_INSTALL_URL="${AVIBE_INSTALL_URL:-https://avibe.bot/install.sh}"
AVIBE_LOG="${AVIBE_LOG:-$HOME/.avibe/avibe.log}"
FNM_DIR="${FNM_DIR:-/opt/fnm}"

export FNM_DIR
export PATH="$FNM_DIR:$PATH"

echo "Initializing avibe container environment..."

eval "$(fnm env --use-on-cd --shell bash)"

echo "Installing or updating AI CLI tools..."
npm install -g @anthropic-ai/claude-code@latest

echo "Installing or updating avibe..."
curl -fsSL "$AVIBE_INSTALL_URL" | bash

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

mkdir -p "$(dirname "$AVIBE_LOG")"
echo "Starting avibe in the background. Logs: $AVIBE_LOG"
vibe >>"$AVIBE_LOG" 2>&1 &
echo "$!" > /tmp/avibe.pid

echo "Development environment ready."
exec "$@"
