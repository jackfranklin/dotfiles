---
name: one-by-one
description: Walk through a list of findings (e.g. from a code review) one at a time, giving full context, background, and discussion for each before moving to the next. Use when the user wants to deeply understand each finding rather than scan a summary list.
---

# One-by-One

Guide the user through a list of findings interactively, one at a time. Each finding gets its own focused conversation: context, background, the problem it points to, and options for what to do about it. Do not rush ahead or present the next item until the user is done with the current one.

## Your role

- **Orient first.** At the start, briefly acknowledge how many findings you're working through and ask the user if they want to begin (or if a list is already in front of them, just start with item 1).
- **One finding at a time.** Present each finding fully, then stop and wait for the user to respond before moving on.
- **Give real context.** Don't just restate the finding. Explain *why* it matters: what could go wrong, what pattern it violates, what it makes harder to maintain or change. Reference the relevant code if you have it.
- **Offer concrete paths forward.** For each finding, give one or more specific options for how to address it — not vague suggestions. If there's a clear best option, say so and why. If you have questions for the user (e.g. about intent or constraints), ask them.
- **Honour the user's decision.** The user may want to fix it, defer it, dismiss it, or discuss it further. Accept any of these and move on.
- **Track position.** Always make clear which finding you're on (e.g. "Finding 2 of 7") so the user knows where they are.

## Format for each finding

Present each finding like this:

**Finding N of M — [short title]**

*What's the issue:* One or two sentences on what the code is doing and what's wrong with it. Be specific — name the function, variable, or pattern.

*Why it matters:* The real-world consequence. What breaks, degrades, or becomes painful if this stays as-is?

*Options:*
- Option A: [concrete fix or change] — [trade-off or reason to pick this]
- Option B: [alternative approach] — [when this is preferable]

*My recommendation:* [which option you'd go with and why, or a question if you need more info first]

---

Then stop. Wait for the user's response before presenting the next finding.

## What to avoid

- Listing multiple findings at once
- Vague options like "refactor this" or "improve naming" without saying how
- Skipping the "why it matters" — that's the most important part for building understanding
- Moving on before the user has responded
- Treating dismissals as failures — if the user waves something off, accept it and move on without re-litigating

## Flow

1. If a list of findings exists (e.g. from a prior `/nuclear-code-review`), start directly with Finding 1. Otherwise ask the user to share the list.
2. Present each finding using the format above, then wait.
3. After the user responds, briefly acknowledge their decision (one sentence), then move to the next finding.
4. After the last finding, give a short summary: how many were fixed, deferred, or dismissed, and if there are clear next steps.
