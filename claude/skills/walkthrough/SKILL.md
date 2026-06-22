---
name: walkthrough
description: >
  Generate an interactive walkthrough of a git diff so the developer can
  understand code the AI has written. Structures the changes into logical steps,
  presents them in the review-plan UI, and answers any questions the developer
  leaves as comments.
---

You are walking a developer through code you have written, so they can
understand it rather than just review it. The output is a structured explanation
piped to the review-plan UI; the developer reads at their own pace, leaves
questions inline, and you answer them when they click Done.

## Steps

### 1. Collect the diff

Get the changes to explain. Use whichever scope is appropriate:

```bash
git diff HEAD          # all uncommitted changes
git diff <base>..<head>  # a specific range
git show <commit>      # a single commit
```

If the user specified a scope (a branch, a commit, a set of files), use it.

### 2. Generate the walkthrough document

Analyse the diff and write a markdown document to a file in the `.jai/tmp/` directory in the current workspace (e.g. `.jai/tmp/walkthrough-<timestamp>.md`). Ensure the directory exists or create it.
Structure it as a sequence of logical steps — not one step per file, but one step
per *concept* or *concern*. A single step might touch several files; a large file
change might warrant two steps. Aim for 3–8 steps total.

Use this template:

```markdown
# Walkthrough: <feature name in plain English>

## Overview

One short paragraph. What problem does this change solve? What is the
approach at a high level? Write for someone who hasn't read the brief.

---

## Step 1: <Verb + subject, e.g. "Introduce the data model">

What changed and — more importantly — *why*. Explain the decision, not just
the mechanics. If there's a non-obvious trade-off or constraint that shaped
the code, say so here.

**Files touched:** `src/models/user.ts`, `src/db/schema.ts`

**Key lines to notice:**

- `src/models/user.ts:42` — the `Role` union type is exhaustive on purpose;
  adding a role in future will produce a type error here to catch missed cases.
- `src/db/schema.ts:18–24` — nullable `deleted_at` instead of a hard delete
  keeps audit history without a separate table.

---

## Step 2: <Next concept>

...

---

## What to look for

A short bulleted list of things you'd like the developer to pay attention to,
or aspects you're less certain about and would welcome a second opinion on.
```

Rules for writing the document:

- Write every step so it makes sense without the developer having the diff open
  side-by-side. Quote short snippets if it helps.
- Prefer explaining *why* over *what*. The diff already shows what changed.
- If a step involves a trade-off you chose between, name the alternatives you
  rejected and why.
- Keep each step focused enough to read in under two minutes.
- Use real file paths and line numbers from the actual diff.

### 3. Open the review UI

```bash
node ~/git/ai-review-plan/dist/cli.js plan \
  --title "Walkthrough: <feature name>" \
  --theme <dark|light> \
  .jai/tmp/walkthrough-<timestamp>.md
```

Use `--theme light` unless the user has expressed a preference for dark mode.

### 4. Read the annotated output

Wait for the CLI to exit. It blocks until the developer clicks Done.

- **No output** — the developer had no questions. Confirm they're happy to proceed
  and delete the temp file.
- **Annotated output** — the developer left questions or concerns. Read each one
  and respond directly in the chat: answer the question, correct any
  misunderstanding, or acknowledge where the code could be clearer. Do not ask
  the developer to re-read the diff themselves.

### 5. Offer a follow-up pass

After answering all questions, ask: *"Would you like another walkthrough pass
with the updated explanation, or are you happy to move on?"* If they want
another pass, revise the document to incorporate the answers inline (so future
readers don't need the Q&A thread) and repeat from step 3.

### 6. Clean up

Delete the temp file once the developer confirms they're done.

## Notes

- The goal is understanding, not approval. Don't frame the walkthrough as
  asking for sign-off; frame it as giving context.
- If the diff is very large (>500 lines), summarise rather than enumerate. The
  document should be readable in 10–15 minutes, not exhaustive.
- If you genuinely aren't sure why you made a particular choice — because the
  AI made a decision that's hard to reconstruct — say so honestly in the step.
  "I chose X; there may be a better approach here" is more useful than a
  confident explanation of the wrong thing.
- Line numbers should match the post-change state of the file, not the diff
  hunk headers, so the developer can open the file and land on the right line.
- **Diagrams**: Use Mermaid diagrams (e.g. `sequenceDiagram`, `flowchart TD`, `stateDiagram-v2` in a fenced code block with language `mermaid`) inside your steps when explaining the sequence of events, data structures, or code architecture introduced by the change.
