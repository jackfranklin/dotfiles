---
disable-model-invocation: true
name: adr
description: Capture an Architecture Decision Record (ADR) for a significant decision made in the current project. Store in the project's adrs/ folder. Use when the user asks to record a decision, log an ADR, or capture why something was built a certain way. PROACTIVELY suggest capturing an ADR whenever a non-obvious architectural choice is made — technology selection, structural trade-offs, rejected alternatives — especially after a discussion where context and reasoning were developed. A good prompt — "Want me to capture this as an ADR?"
---

# ADR Skill

Captures a decision as an Architecture Decision Record in the project's ADR directory. ADRs record the *why* — context, the decision made, alternatives rejected, and consequences — not implementation details.

## 1. Resolve the project root and ADR directory

The project root is the working directory. Check for an existing ADR directory before creating one:

```bash
ls -d adrs/ docs/adr/ docs/decisions/ architecture/decisions/ 2>/dev/null | head -1
```

Use whichever exists. If none exist, default to `adrs/` and create it:

```bash
mkdir -p adrs
```

## 2. Check for existing ADR format

If ADR files exist, read the most recent one to match its format and section naming exactly. Don't impose a different structure on a project that already has a convention.

## 3. Confirm the title and framing before drafting

Before writing a full ADR, confirm with the user in one sentence:

> "I'll capture this as: *'<title>'* — decision: *<one-line summary>*. Does that framing look right?"

This avoids a full redraft if the angle is wrong.

## 4. Determine the next ADR number

```bash
ls adrs/[0-9]*.md 2>/dev/null | sort | tail -1
```

Parse the numeric prefix from the last file (e.g. `0003` from `0003-use-sqlite.md`). Increment by one. If no files exist, start at `0001`.

## 5. Derive the filename

Use the decision title in lowercase kebab-case:

```
adrs/<NNNN>-<kebab-title>.md
```

Example: `adrs/0004-store-adrs-in-top-level-folder.md`

## 6. Write the ADR

Use this template — keep each section concise (a few sentences to a short paragraph):

```markdown
# <NNNN>. <Title>

Date: <YYYY-MM-DD>
Status: <Accepted | Proposed | Deprecated | Superseded by [NNNN](<link>)>

## Context

What situation, constraint, or requirement forced this decision? What was the problem space?

## Decision

What was chosen and why? State it directly.

## Alternatives Considered

What else was evaluated and why was it not chosen? This is the most important section for future readers — capture each rejected option and the specific reason it lost.

## Consequences

What gets easier? What gets harder? What is accepted as a trade-off?
```

**Status values:**
- `Accepted` — decision is in effect
- `Proposed` — under discussion, not yet finalised
- `Deprecated` — no longer relevant but not replaced
- `Superseded by [NNNN](NNNN-<title>.md)` — replaced by a later ADR; also update the superseding ADR to note `Supersedes [NNNN]`

**What belongs here:**
- The reasoning and alternatives considered (with reasons each was rejected)
- Constraints that shaped the choice (team size, existing tooling, latency requirements, etc.)
- Known trade-offs being accepted

**What does not belong here:**
- Implementation steps or how-to instructions
- Code snippets (unless a tiny illustrative example)
- Anything derivable from reading the code

## 7. Present the draft for approval

Show the full ADR text and ask for approval or changes before writing. This is a permanent record — it should be accurate.

## 8. Write the file

Use the Write tool to create the file with the approved content.

## 9. Report back

Tell the user the file path. Offer to stage and commit the file so the decision is captured in git history alongside the code it relates to.
