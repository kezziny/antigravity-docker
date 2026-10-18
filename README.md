# antigravity-docker

[![PR Checks](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/pr-checks.yml)
[![Publish Docker Image](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml/badge.svg)](https://github.com/kezziny/antigravity-docker/actions/workflows/publish.yml)
[![GitHub Container Registry](https://img.shields.io/badge/GHCR-image-blue?logo=docker)](https://github.com/kezziny/antigravity-docker/pkgs/container/antigravity-docker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, multi-architecture Docker image for running the official **Google Antigravity CLI** (`agy`) in an isolated, reproducible container environment.

---

## Highlights

- **Multi-Architecture**: Built for both `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon / ARM).
- **Secure & Stateless**: Zero credentials, tokens, or personal identifiers baked into the image.
- **Non-Root Runtime**: Runs as `antigravity` (UID `1000`, GID `1000`) with passwordless `sudo` access.
- **Persistent Session & Auth**: Mount your host `~/.gemini` directory to reuse your existing authentication, custom skills, rules, and settings seamlessly.
- **Batteries Included**: Includes core developer dependencies (`git`, `curl`, `jq`, `tar`, `sudo`, `ca-certificates`).

---

## Quick Start

### 1. Interactive TUI Mode

Launch an interactive `agy` session mapped to your current directory and host credentials:

```bash
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gemini":/home/antigravity/.gemini \
  ghcr.io/kezziny/antigravity-docker
```

### 2. Print / Non-Interactive Prompt

Run a single prompt in batch mode without opening the interactive TUI:

```bash
docker run -i --rm \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gemini":/home/antigravity/.gemini \
  ghcr.io/kezziny/antigravity-docker -p "Explain the project structure and list key files"
```

### 3. Open a Shell Inside the Container

Inspect the environment or run commands directly:

```bash
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -v "$HOME/.gemini":/home/antigravity/.gemini \
  ghcr.io/kezziny/antigravity-docker bash
```

---

## Using Docker Compose

A pre-configured [`docker-compose.yml`](docker-compose.yml) is included:

```bash
# Run interactive agy session
docker compose run --rm agy

# Run single prompt
docker compose run --rm agy -p "Refactor function in main.py"
```

---

## Recommended Shell Function

For everyday terminal use, add this function to your `~/.bashrc` or `~/.zshrc`:

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
agy-docker
agy-docker --version
agy-docker -p "Review recent git commits"
```

---

## Authentication & Persistence

Antigravity CLI persists configuration, skills, rules, plugins, and session tokens in `~/.gemini/antigravity-cli`.

Mounting `-v "$HOME/.gemini":/home/antigravity/.gemini`:
1. **Preserves Logins**: Authenticate once (or use your host's existing authentication) across container restarts.
2. **Shares Customizations**: Your skills, rules (`.gemini/config/`), and slash commands are instantly available.
3. **Guarantees Zero Secret Leakage**: No API keys or tokens are stored in the image layers or pushed to registries.

---

## Building Locally

To build the image manually on your machine:

```bash
docker build -t antigravity-docker:latest .
```

To test the local image:

```bash
docker run --rm antigravity-docker:latest --version
```

---

## CI/CD Automation

- **PR Checks** ([`.github/workflows/pr-checks.yml`](.github/workflows/pr-checks.yml)): Builds and validates multi-platform (`amd64` and `arm64`) images on pull requests against `master`.
- **Image Publishing** ([`.github/workflows/publish.yml`](.github/workflows/publish.yml)): Builds and pushes tagged multi-architecture images to the [GitHub Container Registry](https://ghcr.io) (`ghcr.io/kezziny/antigravity-docker`) on commits to `master` and version tags (`v*.*.*`).

---

## License

[MIT](LICENSE) © 2026 kezziny
