# Shared skills and subagents

Every custom skill and subagent is written once in this folder and generated
for both Claude Code and Pi. Do not edit `~/.claude/skills`, `~/.claude/agents`,
`~/.pi/agent/skills`, `~/.pi/agent/agents` or `agents/dist/` — they are
generated, read-only, and overwritten by the next build.

```
agents/
  AGENTS.md            shared global instructions (linked by make claude / make pi)
  skills/<name>/       skill sources: SKILL.md plus any supporting files
  subagents/<name>.md  subagent sources
  transform.ts         pure rendering and validation
  build.ts             builds dist/, links each item into place, prunes stale links
  dist/                generated output (gitignored)
```

```bash
make agents        # build and link everything
make agents_specs  # run the build's tests
```

The build needs Node ≥ 24 (native TypeScript).

## What the build does

1. Reads and renders every source in memory and validates cross-references.
   Any error stops the build before anything is written.
2. Checks every install directory. It refuses to run if an install directory
   is itself a symlink, or if an item it wants to link already exists as
   something it does not own.
3. Writes the output to `dist.tmp/` and swaps it in place of `dist/`, so a
   failed write never leaves links pointing at nothing. Generated files are
   read-only; edits to them fail instead of being lost.
4. Links each item into its install directory with an absolute symlink:

   | Output                         | Linked into           |
   | ------------------------------ | --------------------- |
   | `dist/claude/skills/<name>/`   | `~/.claude/skills/`   |
   | `dist/claude/agents/<name>.md` | `~/.claude/agents/`   |
   | `dist/pi/skills/<name>/`       | `~/.pi/agent/skills/` |
   | `dist/pi/agents/<name>.md`     | `~/.pi/agent/agents/` |

5. Removes links that point into `dist/` but whose source is gone. Anything
   else in the install directories (claude.ai's `synced/` skills, skills
   installed by hand) is never touched.

## Skills

A skill is `skills/<name>/SKILL.md` plus any supporting files. Its frontmatter
is [Agent Skills](https://agentskills.io/specification) frontmatter, which both
harnesses read, and is copied unchanged. `name` must equal the directory name
(lowercase words joined by hyphens) and `description` is required.

Every `.md` file in a skill is rendered with the template syntax below. Other
files are copied byte for byte, keeping their execute bits.

## Subagents

A subagent is `subagents/<name>.md`. Its frontmatter is flat `key: value`
lines only: no indentation, block scalars or YAML lists. Values may be bare or
JSON double-quoted. The body is the subagent's system prompt and is rendered
with the template syntax below.

| Key                    | Required | Meaning                                                                                                                            |
| ---------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `name`                 | yes      | must equal the file name without `.md`                                                                                             |
| `description`          | yes      | one line                                                                                                                           |
| `tools`                | yes      | comma list of canonical tools (below); must include at least one tool Claude has, because Claude treats an empty list as all tools |
| `skills`               | no       | comma list of skill names from `skills/`                                                                                           |
| `claude-model`         | no       | `sonnet`, `opus`, `haiku` or `inherit` (default)                                                                                   |
| `pi-model`             | no       | Pi `provider/model`                                                                                                                |
| `pi-thinking`          | no       | Pi thinking level                                                                                                                  |
| `pi-subagent-agents`   | no       | comma list of subagents this one may spawn in Pi; requires the `subagent` tool                                                     |
| `pi-retry-after-tools` | no       | `true` only for read-only agents that are safe to replay after using tools                                                         |

| Canonical tool | Claude Code | Pi         |
| -------------- | ----------- | ---------- |
| `read`         | Read        | read       |
| `write`        | Write       | write      |
| `edit`         | Edit        | edit       |
| `grep`         | Grep        | grep       |
| `find`         | Glob        | find, ls   |
| `bash`         | Bash        | bash       |
| `web_search`   | WebSearch   | web_search |
| `web_fetch`    | WebFetch    | web_fetch  |
| `subagent`     | _(none)_    | subagent   |

Claude subagents cannot spawn subagents, so `subagent` is dropped for Claude.

## Template syntax

`skills/code-review` must stay free of template tokens: the agent-runner
image copies its source directly, not the generated output.

- `{{skills_dir}}` becomes the absolute skills directory of the harness
  (`~/.claude/skills` or `~/.pi/agent/skills`, expanded).
- `{{#claude}}…{{/claude}}` and `{{#pi}}…{{/pi}}` keep their content for that
  harness only. Blocks may span lines but may not nest.
- A block tag that is alone on its line is removed together with that line.
- Only `{{`, an optional `#` or `/`, a lowercase name and `}}` is template
  syntax; other text containing `{{`, such as `${{ secrets.X }}`, is left
  alone. An unknown name, a nested or unclosed block, or a stray closing tag
  stops the build with the file and line.

## Adding a skill or subagent

1. Create `skills/<name>/SKILL.md` or `subagents/<name>.md`.
2. Run `make agents`.
3. Restart or `/reload` the harness to pick it up.

## Migrating

Before this build existed, `~/.claude/skills` and `~/.claude/agents` were
symlinks to whole folders in this repository, and claude.ai wrote its synced
skills into `claude/skills/synced/`. The build refuses to run while an install
directory is a symlink. To migrate a machine once:

1. `git status --ignored --short claude/` should list only
   `claude/skills/synced/`. If it lists anything else, decide where that
   belongs before continuing.
2. Replace the skills link with a real directory and move the synced skills
   into it:

   ```bash
   rm ~/.claude/skills   # removes the symlink only
   mkdir ~/.claude/skills
   mv ~/dotfiles/claude/skills/synced ~/.claude/skills/synced
   rmdir ~/dotfiles/claude/skills/feedback ~/dotfiles/claude/skills
   ```

3. Replace the agents link: `rm ~/.claude/agents && mkdir ~/.claude/agents`.
4. Run `make agents`.

If you move this repository, the old links in the install directories point at
the old location; the build reports them as collisions. Delete those links and
run `make agents` again.

## Skill catalogue

### 1. Exploring an Idea

- `/grill-me` — Stress-test a plan, proposal, or design through an interactive interview.

### 2. Planning

- `/write-plan` — Rigorous TDD plan with exact file paths, real code in every step, and interface contracts between tasks.
- `/review-plan` — Open a plan in the browser for inline review and annotation.

### 3. Implementation & Debugging

- `implement-plan` — Implement an approved plan safely with testing, continuous validation, and atomic commits. (Model-invocable)
- `/implement-orchestrate` — Implement an approved plan as an orchestrator: subagents implement each task, parallel subagents review it.
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
- `lexicon` — Define, review, and audit a project's domain vocabulary across code and docs. (Model-invocable)
- `/writing-great-skills` — Authoring guide and standards for Claude/Gemini skills.

### 7. Ecosystem & Framework Scaffolding

- `/load-cloudflare` — Install Cloudflare's current skill bundle for Pi on demand; it does nothing when already installed.
- `/new-deno-app` — Scaffold a new Deno application.
- `/new-lit-pwa` — Scaffold a new Lit-based Progressive Web App.

### Standalone recipes

Standalone operational guides and reference sheets are located in [`docs/recipes/`](../docs/recipes/):

- [`convert-audio-mono`](../docs/recipes/convert-audio-mono.md) — Audio channel volume analysis and mono conversion.
- [`steam-status`](../docs/recipes/steam-status.md) — Steam startup and client-update diagnostics.
- [`update-neovim`](../docs/recipes/update-neovim.md) — Automated Neovim GitHub release updates.
