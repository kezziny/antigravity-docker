# antigravity-docker

[![PR Checks](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml)
[![Publish Docker Image](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml)
[![GitHub Container Registry](https://img.shields.io/badge/GHCR-image-blue?logo=docker)](https://github.com/kezziny/antigravity-docker/pkgs/container/antigravity-docker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, multi-architecture Docker container configured to run the official **Google Antigravity CLI** (`agy`) out of the box in **Remote Connection mode** (`agy remote-control serve`).

This enables you to run your Antigravity agent daemon inside Docker (on a local machine, home server, NAS, or remote VPS) and control it remotely from any browser or mobile device via [https://antigravity.google.com](https://antigravity.google.com).

---

## Key Features

- **Automatic Remote Connection Mode**: Starts as a remote-control daemon out of the box. No inbound port forwarding or firewall adjustments required (uses secure outbound connection to Google).
- **Multi-Architecture**: Native builds for `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon / ARM).
- **Secure & Stateless**: Zero credentials, tokens, or personal identifiers baked into the image.
- **Non-Root Runtime**: Runs as `antigravity` (UID `1000`, GID `1000`) with passwordless `sudo` access.
- **Persistent Sessions & Auth**: Mount your host `~/.gemini` directory to persist authentication, custom skills, rules, and settings across container restarts.
- **Batteries Included**: Includes core developer dependencies (`git`, `curl`, `jq`, `tar`, `sudo`, `ca-certificates`).

---

## Quick Start (Primary Usage)

### 1. Start with Docker Compose

Launch the agent in the background:

```bash
docker compose up -d
```

Check the startup status and logs:

```bash
docker compose logs -f agy
```

Stop the daemon:

```bash
docker compose down
```

### 2. Start with Docker Run

```bash
docker run -d \
  --name antigravity-cli \
  --hostname antigravity-docker \
  --restart unless-stopped \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gemini":/home/antigravity/.gemini \
  ghcr.io/kezziny/antigravity-docker
```

Once running, access your agent at **[https://antigravity.google.com](https://antigravity.google.com)** under the instance name `antigravity-docker`.

---

## How Authentication Works

Antigravity stores authentication tokens, custom skills, and configuration in `~/.gemini/antigravity-cli`.

### Option A: Reuse Existing Host Authentication (Recommended)
If you have already authenticated `agy` on your host machine, mounting `-v "$HOME/.gemini":/home/antigravity/.gemini` instantly authenticates the container upon launch. No extra login steps needed.

### Option B: Authenticate After Starting in Remote Connection Mode
If you start the container fresh without pre-existing credentials:

1. **Start the container in remote mode:**
   ```bash
   docker compose up -d
   ```
2. **View the container logs:**
   ```bash
   docker compose logs -f agy
   # Or with docker run:
   docker logs -f antigravity-cli
   ```
3. **Follow the verification link:**
   In headless/remote mode, `agy` detects that a desktop browser cannot be launched directly and prints an authorization URL in the logs:
   ```text
   Please visit this URL to authenticate:
   https://accounts.google.com/o/oauth2/auth?...
   ```
4. **Sign in on your computer or phone:**
   Open the link in your browser and authorize access with your Google account.
5. **Session established:**
   The daemon completes the handshake and becomes active. Because `${HOME}/.gemini` is mounted as a volume, your credentials remain saved for all future container restarts.

### Option C: One-Time Interactive Terminal Login
Alternatively, run an interactive sign-in turn before leaving the daemon in the background:

```bash
docker compose run --rm agy agy
```
Follow the interactive prompts to sign in, then start your background daemon with `docker compose up -d`.

---

## Direct CLI Usage & Overrides

Even though the default mode is the remote daemon, you can execute standard `agy` CLI commands or open a shell anytime:

### Single Prompt (Batch Mode)
```bash
docker compose run --rm agy agy -p "Audit this repository for security risks"
```

### Interactive CLI Session
```bash
docker compose run --rm agy agy
```

### Open Container Shell
```bash
docker compose run --rm agy bash
# Or attach to the already running background container:
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

Now you can run:

```bash
agy-docker --version
agy-docker -p "Analyze git log"
```

---

## Configuration Reference (`docker-compose.yml`)

```yaml
services:
  agy:
    image: ghcr.io/kezziny/antigravity-docker:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: antigravity-cli
    hostname: antigravity-docker
    restart: unless-stopped
    stdin_open: true
    tty: true
    volumes:
      - ./:/workspace
      - ${HOME}/.gemini:/home/antigravity/.gemini
    environment:
      - TERM=xterm-256color
```

- **`hostname`**: Determines the instance name displayed on [https://antigravity.google.com](https://antigravity.google.com).
- **`volumes`**:
  - `./:/workspace`: Your project code.
  - `${HOME}/.gemini:/home/antigravity/.gemini`: Preserves authentication and customizations.

---

## Building Locally

To build the image locally:

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
