---
name: code-review
description: >
  Aggressive maintainability review focused on structural simplification, deleting
  complexity, type safety compiler soundness, resource leaks, accessibility,
  localization, and concurrency. Activate this skill ANY TIME the user asks for
  a code review or when you need to perform a senior-level, thorough analysis
  of code changes.
---

# Code Review

Harsh, expert code review focused on implementation quality, aggressive simplification, and long-term maintainability. **Be ambitious.** Do not merely identify local cleanup opportunities; actively search for "code judo" moves that make the implementation dramatically simpler and more elegant.

## Core Principles

1.  **Code Judo**: Actively look for restructurings that delete complexity rather than rearranging it. Reframe the problem so branches, helpers, or layers disappear entirely.
2.  **Zero Spaghetti**: Ban ad-hoc conditionals and scattered special cases in unrelated flows. Push logic into dedicated abstractions or state machines.
3.  **Direct & Boring**: Prefer explicit, legible code over hacky, magical, or thin abstractions that add indirection without value.
4.  **Strict Boundaries**: Enforce clean type contracts. Flag unnecessary optionality, `any`, `unknown`, or excessive casting. Banish `as any` unless explicitly permitted.
5.  **Canonical Home**: Put logic in the correct layer and reuse existing utilities instead of building bespoke ones.

## Workflow

1.  **Context**: Read the commit message (if any) and identify staged/unstaged changes. When diffing against a base branch, use `git diff <base>...HEAD` (three-dot range) rather than `git diff $(git merge-base <base> HEAD) HEAD` — the three-dot form avoids a subshell so it matches the Bash permission allowlist without extra prompts.
2.  **Scope**: Review each changed file statically (do not build or run tests). Inspect the diff and read unchanged files (signatures, constants, types) to understand the full impact.
3.  **Apply Checklists**: For each file, evaluate changes against the checklists below.
4.  **Report**: Synthesize observations into a single cohesive report, grouped by impact (critical bugs, architectural, minor).

## Review Checklist

Do not approve merely because the code works. Apply the following checks:

### 1. Code Smells Baseline (Fowler Refactoring, Ch. 3)

Review the diff against this checklist of common smells. Each smell is a judgment call, never a hard violation. A documented repository standard overrides this baseline.

- **Mysterious Name** — Function, variable, or type name doesn't reveal intent. → Suggest a rename.
- **Primitive Obsession** — Raw strings/primitives used for domain concepts. → Suggest enums, union types, or custom types.
- **Data Clumps** — Same groups of parameters/fields travel together. → Suggest bundling into an object or type.
- **Duplicated Code** — Same logic shape appears in multiple places. → Suggest extracting a shared helper.
- **Shotgun Surgery** — A single logical change forces edits across many files. → Suggest grouping them into one module.
- **Divergent Change** — A module is edited for multiple unrelated reasons. → Suggest splitting the module.
- **Feature Envy** — A method accesses another object's data more than its own. → Suggest moving the method onto the envied object.
- **Speculative Generality** — Hooks/parameters added for future needs. → Suggest deleting/inlining until a real need arises.
- **Message Chains** — Long navigation chains (e.g. `a.b().c()`). → Suggest hiding the traversal behind a single delegate method.
- **Middle Man** — A class/function mostly delegates directly to another. → Suggest removing the middle man.
- **Refused Bequest** — Subclass ignores/overrides inherited features. → Suggest composition over inheritance.
- **Repeated Switches** — Same `switch`/`if` cascade on a type is repeated. → Suggest polymorphism or a shared mapping.

### 2. Quality, Robustness & Maintainability

Reject the change if it introduces:
- **Tangled Flow** — Ad-hoc branching or complex conditional trees. → Suggest guard clauses or state machines.
- **Scattered Logic** — Feature-specific logic placed in shared/common modules. → Suggest moving it to the feature domain.
- **Weak Abstraction** — Indirection that doesn't simplify or reuse code. → Suggest inlining or reverting to direct calls.
- **Redundant State** — Duplicate state or cached values that can be derived. → Suggest deriving values dynamically.
- **Parameter Sprawl** — Function parameter list grows excessively. → Suggest bundling into a config object.
- **Stringly-typed Code** — Raw strings used instead of constants/unions. → Suggest converting to enums or string union types.
- **Loose Typing** — Unjustified usage of `any`, `unknown`, or casting. → Suggest precise types or type guards.
- **Type Boundary Drift** — Deserialization/API boundaries are not validated. → Suggest schema validation (e.g., Zod) or type assertions at the boundary.
- **Resource Leak** — Timers, event listeners, or streams registered without cleanup. → Suggest adding cleanup in teardown hooks (e.g., `ngOnDestroy`).
- **Connection Leak** — DB/network handles left open in error paths. → Suggest closing handles in `finally` blocks.
- **Robustness Flaw** — Unhandled boundary cases (null, empty, large payloads) or ungraceful crash on network/file failures. → Suggest guard clauses and graceful fallback handling.
- **Unsanitized Input** — User/external inputs not escaped. → Suggest escaping control characters (e.g. `*`, `_`, `` ` `` in markdown; `<`, `>`, `&` in HTML).
- **Doc Drift** — Public API changes lack corresponding JSDoc updates. → Suggest updating documentation.
- **Dependency Issues** — Missing or unused dependencies in build configs. → Suggest resolving dependencies.

### 3. Code Reuse & Integration

Flag these opportunities:
- **Duplicate Utility** — Logic duplicates existing helper functions. → Suggest using the existing helper.
- **Hand-rolled Utility** — Inline code implements common utility tasks (path handling, environment/flag checks). → Suggest using standard codebase utilities.
- **Search Rule** — generic-looking code patterns are added without checking. → Actively search for existing helpers using `grep_search`.

### 4. Efficiency & Performance

Reject the change if it introduces:
- **Waste** — Redundant computations, repeated file reads, or duplicate API calls. → Suggest caching or batching.
- **Sequential Async** — Independent async calls run sequentially. → Suggest combining via `Promise.all` or `Promise.allSettled`.
- **Hot-Path Bloat** — Blocking tasks in startup, request handlers, or render loops. → Suggest async processing or lazy loading.
- **TOCTOU Check** — Pre-checking resource existence before operating (e.g. checking file existence). → Suggest operating directly and catching errors (e.g. ENOENT).
- **Broad Scopes** — Reading/loading entire files/datasets when filtering is possible. → Suggest scoped reads or query-level filtering.

### 5. Unit Test Quality (If tests changed)

Reject the change if it introduces:
- **Mock Drift** — Mocks that drift from real signatures or use generic `any` structures. → Suggest type-safe mock frameworks.
- **Bespoke Mocks** — Manual component/DOM construction in tests. → Suggest reusing testing factories or helpers.
- **Weak Assertions** — Assertions that are trivial or verify properties unrelated to the behavior under test. → Suggest precise assertions verifying behavioral side-effects.
- **Bloated Setup** — Repeated boilerplate/mock setups across tests. → Suggest extracting to `beforeEach` hooks or shared helpers.
- **Inconsistent Style** — Test structure diverges from surrounding tests. → Suggest aligning with local patterns.
- **Missing Coverage** — New complex logic or branches added without tests. → Reject change and request new unit tests.
