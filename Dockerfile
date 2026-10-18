FROM debian:bookworm-slim

# Prevent interactive debconf prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies and common developer tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    openssh-client \
    procps \
    sudo \
    tar \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Antigravity CLI (agy)
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin \
    && chmod +x /usr/local/bin/agy \
    && agy --version

# Create non-root antigravity user with passwordless sudo
ARG USERNAME=antigravity
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${USERNAME}" \
    && chmod 0440 /etc/sudoers.d/"${USERNAME}"

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Prepare workspace directory
RUN mkdir -p /workspace && chown -R "${USERNAME}:${USERNAME}" /workspace /home/"${USERNAME}"

USER "${USERNAME}"
WORKDIR /workspace

ENV HOME="/home/${USERNAME}"
ENV USER="${USERNAME}"
ENV PATH="/home/${USERNAME}/.local/bin:/usr/local/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["agy", "remote-control", "serve"]
