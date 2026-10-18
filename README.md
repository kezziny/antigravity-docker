# antigravity-docker

[![PR Checks](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml)
[![Publish Docker Image](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml)
[![GitHub Container Registry](https://img.shields.io/badge/GHCR-image-blue?logo=docker)](https://github.com/kezziny/antigravity-docker/pkgs/container/antigravity-docker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, multi-architecture Docker container configured to run the official **Google Antigravity CLI** (`agy`) out of the box in **Remote Connection mode** (`agy remote-control serve`).

Run your Antigravity agent daemon inside Docker (local workstation, home server, NAS, or remote VPS) and control it remotely from any browser or mobile device via [https://antigravity.google.com](https://antigravity.google.com).

---

## Key Features

- **Out-of-the-Box Remote Control**: Starts as an agent daemon automatically. Connects securely outbound to Google—no open inbound ports or port forwarding required.
- **Multi-Architecture**: Native builds for `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon / ARM).
- **Secure & Stateless**: Zero credentials, tokens, or personal identifiers baked into the image.
- **Non-Root Runtime**: Runs as `antigravity` (UID `1000`, GID `1000`) with passwordless `sudo` access.
- **Persistent Sessions & Auth**: Mount your host `~/.gemini` directory to persist authentication, custom skills, rules, and settings across container restarts.
- **Batteries Included**: Includes core developer dependencies (`git`, `curl`, `jq`, `tar`, `sudo`, `ca-certificates`).

---

## Quick Start with Docker Compose

No need to clone this repository. Create a `docker-compose.yml` anywhere on your system:

```yaml
services:
  antigravity:
    image: ghcr.io/kezziny/antigravity-docker:latest
    container_name: antigravity-cli
    hostname: antigravity-docker   # Name displayed in https://antigravity.google.com
    restart: unless-stopped
    stdin_open: true
    tty: true

    # --- Volumes Configuration ---
    volumes:
      # [MANDATORY] Workspace directory for the agent to inspect and edit code
      - ./:/workspace

      # [MANDATORY FOR PERSISTENCE] Persists Google auth session, skills, and settings
      - ${HOME}/.gemini:/home/antigravity/.gemini

      # [OPTIONAL] Share host Git config with the container
      # - ${HOME}/.gitconfig:/home/antigravity/.gitconfig:ro

      # [OPTIONAL] Share host SSH keys (e.g. for pushing code via SSH)
      # - ${HOME}/.ssh:/home/antigravity/.ssh:ro

    # --- Ports Configuration ---
    # [DEFAULT] NONE needed! Remote Control uses an OUTBOUND connection to Google.
    # [OPTIONAL] Forward ports if your agent runs web apps or dev servers you wish to access from host:
    # ports:
    #   - "3000:3000"
    #   - "8080:8080"

    environment:
      - TERM=xterm-256color
```

### Configuration Reference

| Field | Type | Description |
|---|---|---|
| `image` | **Mandatory** | `ghcr.io/kezziny/antigravity-docker:latest` from GitHub Container Registry. |
| `volumes` | **Mandatory** | `path/to/code:/workspace`: mounts your project directory. |
| `volumes` | **Mandatory** | `${HOME}/.gemini:/home/antigravity/.gemini`: persists login session, custom skills, rules, and settings. |
| `volumes` | *Optional* | `${HOME}/.gitconfig` or `${HOME}/.ssh`: provides git author identity and SSH keys. |
| `ports` | *Optional* | **None required** for Remote Control. Only map ports if you want to access web services or dev servers started by the agent from your host machine (e.g., `"3000:3000"`). |
| `hostname` | *Optional* | Sets the instance name shown on the [Antigravity Web Dashboard](https://antigravity.google.com). |

### Running the Daemon

```bash
# 1. Start the daemon in the background
docker compose up -d

# 2. View logs & check authentication status
docker compose logs -f antigravity

# 3. Stop the daemon
docker compose down
```

Once running, access your agent at **[https://antigravity.google.com](https://antigravity.google.com)** under the instance name `antigravity-docker`.

---

## Alternative: Docker Run

Run directly without Docker Compose:

```bash
docker run -d \
  --name antigravity-cli \
  --hostname antigravity-docker \
  --restart unless-stopped \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gemini":/home/antigravity/.gemini \
  ghcr.io/kezziny/antigravity-docker
```

---

## How Authentication Works

Antigravity stores authentication tokens, custom skills, and configuration in `~/.gemini/antigravity-cli`.

### Option A: Reuse Existing Host Authentication (Recommended)
If you already authenticated `agy` on your host machine, mounting `-v "$HOME/.gemini":/home/antigravity/.gemini` automatically authenticates the container upon launch.

### Option B: Authenticate After Starting in Remote Connection Mode
If starting fresh on a headless machine or VPS without existing credentials:

1. **Start the container:**
   ```bash
   docker compose up -d
   ```
2. **View the startup logs:**
   ```bash
   docker compose logs -f antigravity
   ```
3. **Follow the verification link:**
   In headless/remote mode, `agy` detects that a desktop browser cannot be opened and prints an authorization link:
   ```text
   Please visit this URL to authenticate:
   https://accounts.google.com/o/oauth2/auth?...
   ```
4. **Sign in:**
   Open the URL in any browser (laptop, phone) and authorize your Google account.
5. **Session connected:**
   The daemon completes authentication, saves tokens into the mounted `${HOME}/.gemini` directory, and registers on [https://antigravity.google.com](https://antigravity.google.com). Credentials stay cached for future restarts.

### Option C: One-Time Interactive Terminal Login
Sign in interactively before leaving the daemon running:

```bash
docker compose run --rm antigravity agy
```
Follow prompts to log in, then run `docker compose up -d`.

---

## Direct CLI Usage & Overrides

Run CLI commands or open a container shell anytime:

### Single Prompt (Batch Mode)
```bash
docker compose run --rm antigravity agy -p "Audit this repository for security risks"
```

### Interactive CLI Session
```bash
docker compose run --rm antigravity agy
```

### Open Container Shell
```bash
# In a temporary container:
docker compose run --rm antigravity bash

# Or attach to the running background daemon:
docker exec -it antigravity-cli bash
```

---

## Recommended Shell Function

Add this helper function to your `~/.bashrc` or `~/.zshrc`:

```bash
agy-docker() {
  docker run -it --rm \
    -v "$(pwd)":/workspace \
    -v "$HOME/.gemini":/home/antigravity/.gemini \
    ghcr.io/kezziny/antigravity-docker "$@"
}
```

Usage:

```bash
agy-docker --version
agy-docker -p "Analyze git log"
```

---

## Building Locally

To build the image locally from source:

```bash
docker build -t antigravity-docker:latest .
```

---

## CI/CD Automation

- **PR Checks** ([`.github/workflows/pr-checks.yml`](.github/workflows/pr-checks.yml)): Builds and validates multi-platform (`amd64` and `arm64`) images on pull requests against `master`.
- **Image Publishing** ([`.github/workflows/publish.yml`](.github/workflows/publish.yml)): Builds and pushes tagged multi-architecture images to [GitHub Container Registry](https://ghcr.io) (`ghcr.io/kezziny/antigravity-docker`) on commits to `master` and version tags (`v*.*.*`).

---

## License

[MIT](LICENSE) © 2026 kezziny
