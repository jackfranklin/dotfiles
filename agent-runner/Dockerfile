FROM node:26-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    curl \
    ca-certificates \
    gnupg \
    ripgrep \
    jq \
    fd-find \
    less \
    tree \
    unzip \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh

RUN npm install -g @anthropic-ai/claude-code

# Chrome needs a pile of OS-level shared libraries to actually launch (this is separate from
# whether the zip extracts correctly) — `--install-deps` installs exactly what's needed via
# apt, using Puppeteer's own OS-aware dependency list rather than us hand-maintaining one.
# It requires root, so it has to happen here at build time, before switching to the non-root
# `node` user below. The actual repo-specific pinned Chrome version isn't known until runtime
# (it depends on which repo's package-lock.json agent-run is pointed at), so this just
# triggers a throwaway download purely to get apt to install the shared libraries; the real
# per-repo Chrome download happens later in entrypoint.sh, as the `node` user.
RUN npm install -g @puppeteer/browsers \
    && npx --yes @puppeteer/browsers install chrome --install-deps \
    && npm uninstall -g @puppeteer/browsers \
    && rm -rf /root/.cache/puppeteer /var/lib/apt/lists/*

WORKDIR /work
RUN chown node:node /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
