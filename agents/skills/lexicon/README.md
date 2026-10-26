# Lexicon skill: usage notes

`SKILL.md` is copied verbatim from
[paulirish/dotfiles](https://github.com/paulirish/dotfiles/blob/main/agents/skills/lexicon/SKILL.md).
Keep it unmodified so upstream changes can be pulled with a straight copy; put
local notes here instead. This README is not loaded into agent context.

The skill maintains a small `LEXICON.md`: one canonical name per concept that
humans or agents tend to get wrong, then checks code and docs against it. It has
three modes. On a project that has never used it, use them in this order.

## 1. Naming critique (optional first step)

> "Use the lexicon skill to do a naming critique of this project."

Surveys specs, schemas, public types and core code, and flags misleading,
overloaded or inconsistent names (two names for one idea, one name for two
ideas). It suggests renames but does **not** create a lexicon. A cheap way to
judge whether the project needs one.

## 2. Create the lexicon

> "Use the lexicon skill to create a lexicon for this project."

- **Load:** looks for an existing `LEXICON.md`, `GLOSSARY.md`, `TERMS.md`,
  `CONTEXT.md` or README terms section; asks which is authoritative if several.
- **Survey:** parallel subagents pull candidate terms from docs, from
  schemas/APIs, and from places where the code disagrees about meaning.
- **Filter hard:** a term is admitted only if its entry prevents a real naming
  or interpretation mistake. Frequency or importance isn't enough. Expect a
  short list, not a glossary.
- **Challenge:** a skeptical subagent reviews proposed entries before writing.
- **Write:** clear-cut terms are written immediately, with a summary list.
- **Ask:** contested terms come back as questions ("is a *session* the same as
  a *connection*?"). The skill never picks a winner itself.
- **Link:** adds a pointer to `LEXICON.md` in `AGENTS.md`.

Tips:

- Seed it with confusions you already know about ("we use *job*, *task* and
  *run* interchangeably"). These beat a blind sweep.
- Expect questions. Your answers become the `_Avoid_` entries that make later
  audits useful.
- Commit `LEXICON.md` on its own before any renames, so the vocabulary decision
  is separate from the refactor.

## 3. Audit against it periodically

> "Use the lexicon skill to audit the codebase against LEXICON.md."

Finds avoided terms, misuse of canonical names and newly invented vocabulary.
Fixes are sorted into safety tiers:

- **Tier 1:** comments, prose, unexported names.
- **Tier 2:** shared types and interfaces. Needs approval plus typecheck/tests.
- **Tier 3:** persisted schemas, public APIs, CLI flags, logs. Needs a
  migration plan.

Only approved fixes are applied. Good times to run it: before a release, after a
big feature lands, or after new contributors (human or agent) have been active.

## Day to day

With `AGENTS.md` pointing at the lexicon, agents should use the canonical terms
unprompted. Smaller requests also work: "add *X* to the lexicon", "is *foo* or
*bar* the right name for this?"

## When not to bother

Small projects and personal scripts: the survey and subagents cost more than
they save. It pays off when a project has real domain concepts (billing,
scheduling, protocols) and several people or agents writing about them.
