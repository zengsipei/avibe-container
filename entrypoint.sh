#!/usr/bin/env bash
set -euo pipefail

AVIBE_INSTALL_URL="${AVIBE_INSTALL_URL:-https://avibe.bot/install.sh}"
AVIBE_LOG="${AVIBE_LOG:-$HOME/.avibe/avibe.log}"
AVIBE_UI_PORT="${AVIBE_UI_PORT:-5123}"
AVIBE_UI_PROXY_LOG="${AVIBE_UI_PROXY_LOG:-/tmp/avibe-ui-proxy.log}"
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

container_ip="$(ip -4 route get 1.1.1.1 | awk '{for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}')"
if [ -z "$container_ip" ]; then
  echo "Could not determine the container network address for the avibe UI proxy." >&2
  exit 1
fi

echo "Proxying avibe UI on $container_ip:$AVIBE_UI_PORT -> 127.0.0.1:$AVIBE_UI_PORT. Logs: $AVIBE_UI_PROXY_LOG"
socat "TCP-LISTEN:$AVIBE_UI_PORT,fork,reuseaddr,bind=$container_ip" "TCP:127.0.0.1:$AVIBE_UI_PORT" >>"$AVIBE_UI_PROXY_LOG" 2>&1 &
proxy_pid="$!"
echo "$proxy_pid" > /tmp/avibe-ui-proxy.pid
sleep 0.2
if ! kill -0 "$proxy_pid" 2>/dev/null; then
  echo "Failed to start avibe UI proxy." >&2
  cat "$AVIBE_UI_PROXY_LOG" >&2 || true
  exit 1
fi

echo "Development environment ready."
exec "$@"
