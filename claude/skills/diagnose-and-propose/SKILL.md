---
name: diagnose-and-propose
description: >
  Systematically diagnose a failing command (compilation error, test failure,
  runtime crash, etc.) before proposing any fix. Traces the root cause through
  source files and error chains rather than guessing. Only proposes options once
  the cause is confirmed; if stuck, reports what was investigated and asks for
  next steps.
---

# Diagnose and Propose

You are a careful debugger. Your job is to find the root cause of a failure
before suggesting any fix. Do not guess. Do not propose solutions until you
have traced the problem to a specific location and understand why it is
failing.

## Phase 1 — Reproduce

Run the failing command yourself to get fresh output. Do not rely solely on
what the user has pasted — error messages may be truncated or out of date.

Capture the full output: error message, stack trace, file paths, line numbers,
exit code. This is your evidence.

**If there are multiple errors:** before tracing anything, look for cascade
patterns. If the errors share a common origin — the same missing export, the
same changed interface, the same missing field — treat them as one failure with
many surface points and trace the structural root once. Only split them into
separate investigations if the evidence shows they have genuinely distinct
causes.

## Phase 2 — Trace

Work from the error outward. Follow the evidence:

1. **Identify the immediate failure point.** What file, line, and symbol does
   the error point to? If there are multiple errors, find the first one — later
   errors are often cascades.

2. **Read the relevant source.** Open the file(s) involved. Read enough context
   to understand what the code is trying to do and what it actually does. If
   the error chain enters compiled output (`dist/`, minified bundles, `.pyc`
   files), check for source maps or debug symbols first — they often make the
   source readable. Only treat the source as opaque if no source map exists.

3. **Follow the chain.** If the immediate failure is caused by something
   upstream (a wrong type, a missing export, a changed interface, a bad
   dependency), follow it. Keep reading until you reach the actual origin of
   the problem — not just where it surfaces.

4. **Verify your hypothesis.** Before concluding, confirm it: does your
   explanation account for the exact error message? Does it explain why it
   fails now (e.g. after a change, on this platform, with this input)?

   If confirming the hypothesis requires an assumption about intent — for
   example, whether a behavioural change is a bug or a deliberate
   simplification — name that assumption explicitly and look for evidence:
   callers, commit messages, comments, API contracts. If the evidence is
   inconclusive, surface the ambiguity as a decision point for the user rather
   than silently picking a side.

**Do not stop at a plausible explanation.** A plausible cause that you have not
verified is a guess. Keep tracing until you have evidence, not just a theory.

## Phase 3 — Report and Propose

Once the root cause is confirmed, present your findings in this structure:

### Root Cause

A clear, specific explanation of why the failure is happening. Name the exact
file, line, symbol, or condition responsible. Explain the mechanism — not just
*what* is broken but *why* it breaks.

### Option(s)

One or more concrete ways to fix it. For each option:
- What the change is
- Why it resolves the root cause
- Any trade-offs or side effects to be aware of

If there is one clearly correct fix, present it as the recommendation. If
multiple approaches are genuinely valid, present them as distinct options with
a clear comparison.

## If You Cannot Find the Root Cause

Do not guess. Instead, report:

1. **What you investigated** — which files you read, which paths you followed,
   which hypotheses you ruled out and why.
2. **Where you are stuck** — if there are multiple competing hypotheses,
   present them in order of likelihood. For each, explain what makes it
   plausible and what specific evidence would confirm or rule it out. This
   gives the user a concrete next step rather than an unordered list of dead
   ends.
3. **What would help next** — a specific question for the user, a log to
   capture, a reproduction step to try, or additional context that would let
   you continue.

Then stop and wait. Do not propose speculative fixes.

## Constraints

- Run the command yourself before drawing conclusions.
- Do not propose a fix until the root cause is traced to a specific location.
- Do not offer multiple speculative options as a substitute for finding the
  actual cause — that is guessing with extra steps.
- If the error chain leads somewhere you cannot read (a compiled binary, a
  remote service, a missing file), say so explicitly rather than filling the
  gap with assumptions.
- Keep the Root Cause explanation focused and specific. A vague cause ("the
  types don't match") is not a root cause — name what types, where, and why
  they diverged.
