# Claude Skills

Custom skills for Claude Code. Each subdirectory is a skill with a `SKILL.md` manifest.

Skills are symlinked into `~/.claude/skills/` via `make claude`.

See [WORKFLOW.md](./WORKFLOW.md) for how the skills fit together across the engineering cycle.

## Skills

| Skill | Description |
|-------|-------------|
| `adr` | Capture an Architecture Decision Record for a significant decision |
| `automated-doubt` | Post-implementation audit from multiple critical perspectives |
| `code-quality-reviewer` | Review for hacky patterns, redundant state, and leaky abstractions |
| `code-reuse-reviewer` | Identify opportunities to reuse existing utilities and helpers |
| `code-simplifier` | Run reuse, quality, and efficiency reviewers together |
| `doc-clarity-opportunity` | Find opportunities to improve documentation and code clarity |
| `efficiency-reviewer` | Review for performance and efficiency improvements |
| `verify-plan-assumptions` | Audit a spec or plan against the live codebase for stale assumptions |
| `feedback` | Log and retrieve feedback on AI-assisted work sessions |
| `fresh-eyes-amend` | Review recent changes as if seeing them for the first time |
| `grill-me` | Stress-test a plan via relentless interviewing |
| `handoff` | Generate a handoff document summarising in-progress work |
| `handoff-search` | Search existing handoff documents |
| `ideate` | Brainstorm approaches to a problem |
| `jack-references` | Manage a personal technical reference library |
| `later` | Log items to revisit later using a local JSON file |
| `new-deno-app` | Scaffold a new Deno application |
| `new-lit-pwa` | Scaffold a new Lit PWA |
| `nuclear-code-review` | Aggressive maintainability review focused on deleting complexity |
| `preflight` | Minimalism ladder check before planning or implementation (see below) |
| `review-diff` | Review a git diff |
| `review-plan` | Present a plan for inline human annotation via browser UI |
| `verify-mechanical-change` | Verify a change is purely mechanical with no behavioural impact |
| `walkthrough` | Interactive walkthrough of a git diff for the developer |
| `write-detailed-implementation-plan` | Write a rigorous TDD implementation plan saved to `.jai/detailed-plans/` (see below) |

## Inspiration

### Ponytail → `preflight`

[`preflight`](./preflight/) is inspired by the [Ponytail plugin](https://github.com/DietrichGebert/ponytail), which advocates running a minimalism decision ladder before writing any code:

> Is it necessary? → stdlib? → native platform feature? → existing dep? → one-liner? → only then: minimal implementation.

Rather than adopting Ponytail's lifecycle hooks, the concept is captured as a deliberate skill invoked before planning — the ladder runs, produces findings, and the verdict feeds into `write-detailed-implementation-plan` or directly into implementation.

### obra/superpowers → `write-detailed-implementation-plan`

[`write-detailed-implementation-plan`](./write-detailed-implementation-plan/) is adapted from the [obra/superpowers writing-plans skill](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md). The core ideas are preserved — no placeholders, TDD cycle in every task, exact file paths and code in every step, interface contracts between tasks, and a self-review pass — with superpowers-specific scaffolding removed and the output path adjusted to `.jai/detailed-plans/`.
