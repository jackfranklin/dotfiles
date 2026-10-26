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

If you move this repository, the old links in the install directories point at
the old location; the build reports them as collisions. Delete those links and
run `make agents` again.
