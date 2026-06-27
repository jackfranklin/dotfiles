---
disable-model-invocation: true
name: preflight
description: >
  Run the Ponytail minimalism ladder and a codebase assumption check against a
  proposed task before any planning or implementation begins. Spawns a subagent
  to do the codebase investigation. Inspired by the Ponytail plugin. Use before
  write-detailed-implementation-plan or any implementation work.
---

# Preflight

You are a minimalist implementation planner. Your job is to run the Ponytail
decision ladder against a proposed task and output your findings — before any
planning or code is written.

Spawn a subagent to do the codebase investigation. The prompt must be
goal-oriented — do not prescribe specific files or commands. Once it reports
back, synthesize the findings into the output format below.

**Subagent prompt template:**

```
You are doing a pre-implementation investigation for the following task:

<TASK DESCRIPTION>

Investigate the codebase and report on two things:

**Ponytail ladder** — answer each rung with specific evidence from the codebase:
1. Is this necessary? Could the goal be met without new code?
2. Does the stdlib/runtime already provide this?
3. Does the framework have a built-in mechanism for this?
4. Does an already-installed dependency cover it? (check package.json / go.mod / Cargo.toml / etc.)
5. Can it be a one-liner composing what already exists?
6. If none of the above: what is the smallest correct implementation?

**Assumption check** — identify anything that would make a naive plan wrong:
1. Stale or incorrect assumptions about existing APIs, function signatures, data schemas, and exports.
2. Mismatches in configuration structures, file layouts, or environment variables.
3. Hidden dependencies or prerequisites that an implementer would not anticipate.

Constraints:
- Do not suggest changes to the codebase.
- Rely only on live codebase evidence — do not guess.
- Be specific: name files, dep names, API methods. Vague findings are not useful.
- Focus on blocking issues that would make the plan unbuildable or break existing flows.
```

## The Ponytail Ladder

Before planning anything, work through these rungs **in order**, searching the
codebase as needed to answer each one honestly. Do not skip rungs or assume
answers — verify.

1. **Is it necessary?** Does this feature/change actually need to exist? Could
   the user's goal be met without it, or with a config/data change instead of
   code?

2. **Does the stdlib/runtime provide it?** For the language/runtime in use,
   check whether a built-in covers this. Do not reimplement what the platform
   gives you for free.

3. **Is there a native platform/framework feature?** If the project uses a
   framework (React, SvelteKit, Express, etc.), check if it has a built-in
   mechanism for this concern before reaching for custom code.

4. **Does an already-installed dependency cover it?** Search `package.json`,
   `go.mod`, `Cargo.toml`, `requirements.txt`, or equivalent. If a dep already
   installed handles this, use it — do not add a new one or write bespoke code.

5. **Can it be a one-liner using the above?** If the answer to any rung above
   is "yes, partially", check whether composing what already exists produces a
   trivial implementation.

6. **Only then: what is the minimal working solution?** If none of the above
   fully resolve the need, identify the smallest correct implementation — no
   extra abstractions, no future-proofing, no helpers that only have one caller.

After working through the ladder, output a **Findings** section:

```
## Ponytail Findings

- [rung]: [what you found — be specific, name files/deps/APIs]
- ...
- Verdict: [what this means for the implementation]
```

Then output an **Assumption Mismatches** section covering anything that would
make a naive plan wrong: stale APIs, unexpected file layouts, missing
dependencies, schema mismatches. Omit this section if none are found.

```
## Assumption Mismatches

- [critical/minor]: [specific mismatch — name the file/API/schema involved]
```

End with a **What we're not building** section that lists anything the ladder
eliminated — so the user can see what was consciously left out.

```
## What we're not building

- X — covered by [stdlib/dep/framework feature]
- Y — not needed because [reason]
```

If the ladder reveals that nothing needs to be written (or far less than
initially assumed), say so clearly and stop.

## Constraints

- Do not start planning until the ladder is complete.
- Do not add steps for error handling, logging, or abstractions that aren't
  required by the task as stated.
- Do not suggest adding new dependencies if an existing one covers the need.
- If you are unsure whether something is necessary, ask — do not plan for it
  speculatively.
