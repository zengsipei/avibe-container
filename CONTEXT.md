# Project Context

## Purpose

This repository packages an AI-agent-oriented development container environment for running avibe while writing code. The repo is not the avibe application itself; it is the wrapper that prepares a coding environment and starts avibe in a reproducible container.

## Domain language

- **avibe**: The upstream tool started through the `vibe` command.
- **development container**: The Debian-based environment that contains compilers, language runtimes, Git tooling, shell utilities, and CLI dependencies used by AI agents while writing code.
- **fnm-managed Node**: Node.js is installed with `fnm` under `/opt/fnm`, and the image activates the latest LTS line instead of Debian's packaged Node version.
- **published image**: `xiao806852034/avibe-container`, the Docker Hub image built from this repository.
- **entrypoint**: `entrypoint.sh`, the startup script that reruns the official avibe install script, starts `vibe` in the background, and then runs the foreground shell or command.
- **avibe UI proxy**: A `socat` process that listens on the container network address and forwards to avibe's loopback-only UI server on `127.0.0.1:5123`.
- **persistent root**: The local `.root/` directory mounted as container `/root`, used for CLI configuration, caches, and avibe state.
- **workspace**: The repository mounted at `/workspace` for code editing inside the container.

## Current boundaries

- The project owns Docker/Compose configuration, development tooling, and startup orchestration.
- The project owns the Docker Hub image packaging for `xiao806852034/avibe-container`.
- The project does not own avibe source code or avibe feature behavior.
- Runtime state and credentials belong in `.root/` or `.env`, both ignored by Git.
