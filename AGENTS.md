# Dotfiles Pi configuration

This repository contains Jack's personal dotfiles and uses explicit Makefile-managed symlinks rather than Stow. Its Pi configuration lives under `pi/`. Run `make pi` to symlink `settings.json`, `permissions.json`, and `extensions/` into `~/.pi/agent/`; do not edit those symlinked copies directly.

Pi reads this top-level `AGENTS.md` when it starts in this repository. It also searches the current directory and its parents for `AGENTS.md` or `CLAUDE.md`; this file is repository-specific and is deliberately not installed as global Pi context.

## Repository conventions

- Neovim configuration is in `nvim/`; run `make lua_specs` for its Lua tests.
- Fish functions are in `fish/functions/`.
- Claude's global configuration and skills are in `claude/`; `make claude` installs their symlinks.
- Format JavaScript/TypeScript with the repository Prettier configuration: semicolons, trailing commas, and single quotes.

## Pi configuration

- `settings.json` selects the light theme, OpenAI Codex as the default provider/model, high thinking, enabled models, and discovers skills from `~/.claude/skills`.
- `permissions.json` is used by the permissions extension. It contains glob rules that classify commands and file operations as safe, approval-required, or blocked.
- `extensions/` is symlinked to `~/.pi/agent/extensions/`. Pi auto-discovers a top-level `.ts` extension or a nested `index.ts` in that directory.
- `make pi_deps` installs the production dependencies needed by `extensions/web-fetch`.
- `make pi_specs` runs the permissions extension's Node test suite.

Reload or restart Pi after changing an extension, its configuration, or a subagent definition. A running subagent is not affected by later configuration changes.

## Extensions

### `minimal-footer`

Replaces Pi's standard footer. It displays context-window usage, cumulative session cost (and whether the active model uses a subscription), the active model, thinking level, and Git branch. It updates on session start, model changes, and thinking-level changes.

### `permissions`

Safety gate for `bash`, `read`, `write`, and `edit` calls. Decisions are made in this order: hardcoded dangerous command blocks, configured `block` globs, configured `safe` globs, configured `prompt` globs, risky shell redirections, and writes/edits outside the working directory or into sensitive system paths.

In an interactive Pi session, approval can allow or ban an operation once or persist a matching rule in `permissions.json`. In headless contexts, including subagents, approval-required operations are blocked. Approval requests and decisions are appended to `~/.pi/agent/permission-approvals.jsonl`.

### `skill-metrics`

Records explicit `/skill:<name>` invocations by absolute project path in `~/.pi/agent/skill-metrics.sqlite` (SQLite WAL mode). Use `/skill-metrics` for the current project or `/skill-metrics all` for every project. Extension-injected messages and unknown skill names are not recorded.

### `subagents`

Registers the `subagent` tool, which starts isolated, headless child Pi processes. Children receive only the supplied task and working directory; they do not inherit the parent conversation or skills. The parent shows live progress and receives the child's final text as the result.

Available agents:

- `scout`: read-only local codebase reconnaissance (`read`, `grep`, `find`, `ls`).
- `researcher`: public-web research only (`web_search`, `web_fetch`).
- `implementer`: performs a discrete implementation task from a plan already established by the parent. It must receive scope, constraints, and acceptance criteria. Do not use it for general queries, exploration, architectural decisions, or planning. It may delegate only to `scout` and `researcher`.

Subagents load the permissions extension. Operations that would need an interactive approval fail closed. `extensions/subagents/config.json` limits concurrent child processes; agent definitions are in `extensions/subagents/agents/`.

### `web-fetch`

Registers `web_fetch`, which fetches a URL and returns readable Markdown. It extracts HTML with Readability and Turndown, supports plain text and PDFs, handles some Next.js RSC pages, and falls back to Jina Reader for JavaScript-rendered pages. Responses are capped at 50 KB or 2,000 lines.

### `web-search`

Registers `web_search`, which queries Exa and returns titles, URLs, snippets, authors, and publication dates. It supports a base query, exact phrases, exclusions, and domain include/exclude filters. Provide credentials through `EXA_API_KEY` or `extensions/web-search/auth.json` (copied from `auth.example.json` and kept out of version control). Use one search call per distinct research angle.

## Extension development

Pi extensions are TypeScript modules loaded through jiti. They register tools, commands, UI, or lifecycle-event handlers through `ExtensionAPI`. The authoritative Pi extension documentation is installed with Pi at `docs/extensions.md`; this repository's source and local behavior are documented in each extension, especially `extensions/permissions/README.md` and `extensions/subagents/README.md`.
