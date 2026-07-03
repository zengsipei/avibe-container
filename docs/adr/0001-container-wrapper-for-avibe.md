# ADR 0001: Package avibe as a container wrapper

## Status

Accepted

## Context

This repository is used to run avibe from a local, repeatable container environment while providing a practical coding environment for AI agents. The initial files already centered on `compose.yaml` and `entrypoint.sh`, so the repo should document and support that role directly.

## Decision

Use Docker Compose as the local user entry point, backed by a Debian image built from `Dockerfile`.

The image installs common development dependencies such as compilers, Git/GitHub tooling, shell utilities, Python, and diagnostics tools. Node.js is installed through `fnm` under `/opt/fnm`, using the latest LTS line rather than Debian's packaged Node/npm versions. The image also includes `cloudflared` for avibe's native remote-access tunnel. The startup script reruns the official avibe install script at runtime to install or upgrade avibe, starts `vibe` in the background, then starts `vibe remote start` when remote access is already paired.

Mount the repository to `/workspace` for coding. Mount local `.root/` to container `/root` so CLI auth, caches, and avibe state survive container recreation without being committed.

Use `xiao806852034/avibe-container` as the canonical image name. Local Compose builds tag that image directly, and GitHub Actions publishes the same image name to Docker Hub.

## Consequences

- Users can enter the environment with `docker compose run --rm avibe`.
- Published images target Docker Hub at `xiao806852034/avibe-container`.
- Runtime state is intentionally outside Git.
- Changes to the development toolchain are made in `Dockerfile`; changes to avibe startup behavior are made in `entrypoint.sh`.
