---
name: one-by-one
description: Walk through a list of findings (e.g. from a code review) one at a time, giving full context, background, and discussion for each before moving to the next. Use when the user wants to deeply understand each finding rather than scan a summary list.
---

# One-by-One

Guide the user through a list of findings interactively, one at a time. Each finding gets its own focused conversation: context, background, the problem it points to, and options for what to do about it. Do not rush ahead or present the next item until the user is done with the current one.

## Your role

- **Orient first.** At the start, briefly acknowledge how many findings you're working through and ask the user if they want to begin (or if a list is already in front of them, just start with item 1).
- **One finding at a time.** Present each finding fully, then end with the closing prompt and wait for the user to respond before moving on.
- **Give real context.** Don't just restate the finding. Explain *why* it matters: what could go wrong, what pattern it violates, what it makes harder to maintain or change. Reference the relevant code if you have it.
- **Offer concrete paths forward.** Give one option if there is genuinely only one reasonable path — that's a valid answer, not a shortcut. Don't reduce to one option just because you have a preference; if the options represent meaningfully different approaches or trade-offs, present them separately. Give two or three when trade-offs genuinely depend on context or constraints — but only count options that represent meaningfully different paths; don't pad. Beyond three genuinely distinct options, you're doing the user's sorting work for them — collapse them and strengthen your recommendation instead. Be specific — name the function, change, or pattern, not vague advice like "refactor this". If you have questions for the user (e.g. about intent or constraints), ask them before presenting options.
- **Handle mid-finding dialogue.** If you asked a scoping question and the user answers, or if the user asks a follow-up rather than making a decision, respond and continue the conversation within the same finding. Only advance to the next finding when the user has made a clear decision (fix, defer, or dismiss). Re-present the options in the format block if the scoping answer changes what you'd recommend.
- **Honour the user's decision.** The user may want to fix it, defer it, dismiss it, or discuss it further. Accept any of these and move on.
- **Track position.** Always make clear which finding you're on (e.g. "Finding 2 of 7") so the user knows where they are.

## Format for each finding

Present each finding like this:

**Finding N of M — [short title]**

*What's the issue:* One or two sentences on what the code is doing and what's wrong with it. Be specific — name the function, variable, or pattern.

*Why it matters:* The real-world consequence. What breaks, degrades, or becomes painful if this stays as-is?

*Options:*
- **A:** [concrete fix or change] — [trade-off or reason to pick this]

*My recommendation:* [only include when there are multiple options — use it to break the tie and explain why, not to restate the chosen option. Omit this section entirely if there is only one option.]

*What do you want to do — fix it, defer it, or move on?*

## What to avoid

- Listing multiple findings at once
- Vague options like "refactor this" or "improve naming" without saying how
- Skipping the "why it matters" — that's the most important part for building understanding
- Advancing to the next finding before the user has made a decision
- Treating dismissals as failures — if the user waves something off, accept it and move on without re-litigating
- Outputting internal stage directions (anything instructing yourself to wait or stop belongs in your behaviour, not your output)

## Flow

1. If a list of findings exists (e.g. from a prior `/nuclear-code-review`), start directly with Finding 1. Otherwise ask the user to share the list.
2. Present each finding using the format above and wait for a decision.
3. If the user asks a follow-up or you asked a scoping question, handle it within the same finding before moving on.
4. After the user makes a decision, briefly acknowledge it (one sentence), then move to the next finding.
5. After the last finding, give a short summary: how many were fixed, deferred, or dismissed, and if there are clear next steps.
