# Claude Skills

Custom skills for Claude Code. Each subdirectory under `skills/` is a skill with a `SKILL.md` manifest. The `skills/` directory is symlinked into `~/.claude/skills/` via `make claude`.

> **Note:** keep this file *out* of `skills/`. Claude scans that directory and treats every top-level `.md` file as a skill manifest, so docs placed there produce "description is required" errors.

---

## Engineering Lifecycle

### 1. Exploring an Idea
- `/design-discussion` — Collaboratively discuss designs, evaluate trade-offs, and explore alternative implementation approaches. (Model-invocable)
- `/grill-me` — Stress-test a plan, proposal, or design through an interactive interview.

### 2. Planning
- `/write-plan` — Rigorous TDD plan with exact file paths, real code in every step, and interface contracts between tasks.
- `/review-plan` — Open a plan in the browser for inline review and annotation.

### 3. Implementation & Debugging
- `implementing` — Implement an approved plan safely with testing, continuous validation, and atomic commits. (Model-invocable)
- `diagnose-and-propose` — Systematically diagnose a failing command (compilation error, test failure, runtime crash) before proposing a fix. (Model-invocable)
- `resolve-merge-conflict` — Resolve in-progress git merge/rebase conflicts cleanly. (Model-invocable)
- `/one-by-one` — Execute a plan step-by-step with interactive checkpoints.

### 4. Review & Quality
- `code-review` — Aggressive maintainability review focused on structural simplification, deleting complexity, and type safety. (Model-invocable)
- `/fresh-eyes-amend` — Review recent local changes with a fresh perspective before amending or committing.
- `/review-diff` — Open a git diff in the browser for visual review.
- `/github-code-review` — Fetch and review GitHub pull requests.

### 5. Communication & Clarification
- `/wtf` — Re-pitch the preceding response in clear, plain language using ASD-STE100 technical English.

### 6. Architecture, Handoff & Reference
- `/adr` — Record an Architectural Decision Record while the reasoning is fresh.
- `/handoff` — Summarize in-progress work as a GitHub Issue for a future session or collaborator.
- `/later` — Log a backlog item or idea as a GitHub Issue without losing the current thread.
- `/jack-references` — Save, search, and manage personal technical reference notes.
- `/writing-great-skills` — Authoring guide and standards for Claude/Gemini skills.

### 7. Ecosystem & Framework Scaffolding
- `/cloudflare`, `/wrangler`, `/workers-best-practices` — Cloudflare Workers architecture, bindings, and deployment workflows.
- `/new-deno-app` — Scaffold a new Deno application.
- `/new-lit-pwa` — Scaffold a new Lit-based Progressive Web App.

---

## Standalone Recipes

Standalone operational guides and reference sheets are located in [`docs/recipes/`](../docs/recipes/):
- [`ast-grep`](../docs/recipes/ast-grep.md) — Structural syntax-tree code searching cheat sheet.
- [`convert-audio-mono`](../docs/recipes/convert-audio-mono.md) — Audio channel volume analysis and mono conversion.
- [`update-neovim`](../docs/recipes/update-neovim.md) — Automated Neovim GitHub release updates.
