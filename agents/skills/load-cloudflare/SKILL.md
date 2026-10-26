---
name: load-cloudflare
description: Install Cloudflare's current Pi skill bundle when explicitly requested. Does nothing when it is already installed.
disable-model-invocation: true
---

# Load Cloudflare Skills

Use this skill only when the user explicitly invokes it. This dotfiles repository deliberately does not vendor Cloudflare's skill bundle.

1. Fetch and read the current official setup instructions: <https://developers.cloudflare.com/agent-setup/prompt.md>.
2. If `~/.pi/agent/skills/cloudflare/SKILL.md` exists, report that the Cloudflare skills are already installed and stop. Do not update or reinstall them.
3. Otherwise, follow any Pi-specific instructions in the fetched prompt. If it has no Pi-specific section, install the current bundle for Pi with:

   ```bash
   DISABLE_TELEMETRY=1 npx -y skills add cloudflare/skills --skill '*' --yes --global --agent pi
   ```

4. Do not configure Cloudflare MCP servers unless the official prompt contains Pi-specific MCP instructions.
5. Tell the user to restart Pi. It discovers newly installed skills at startup.

The installed bundle lives in `~/.pi/agent/skills/`, outside this repository. Update it only when the user explicitly asks; this skill intentionally treats an existing bundle as current enough.
