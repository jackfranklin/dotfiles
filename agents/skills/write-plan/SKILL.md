---
disable-model-invocation: true
name: write-plan
description: >
  Write a right-sized, reviewable implementation plan as a series of focused
  tasks, with exact file paths, interface contracts, behavioral test specifications,
  and verification commands. Focuses on architectural intent and test coverage
  without dumping raw test or implementation code. Performs pre-planning preflight
  investigation and Ponytail ladder checks before drafting. Reviews the plan
  with the user task by task before storing an explicitly approved plan on the
  relevant GitHub issue.
---

# Write Plan

Write a rigorous implementation plan assuming the engineer has zero context
about the codebase and will execute tasks in isolation. Every step must
contain everything they need — no references to "fill in later", no vague
instructions, no placeholders.

DRY. YAGNI. TDD. Frequent commits. Focus on clear contracts, behavioral specs,
and independent verification rather than premature code dumps. Prefer designs
that are easy to explain, reason about locally, and change.

## GitHub body safety — mandatory

Never place a Markdown plan in a shell-quoted `gh --body` argument. Backticks, `$`, and command examples in Markdown are shell syntax inside double-quoted Bash strings and can execute commands or leak their output into GitHub.

Write every issue body/comment to a temporary Markdown file outside the repository with the file-writing tool, then pass it with `--body-file`. Never use `--body "..."`, `--body "$(...)"`, backticks in a shell string, or an unquoted heredoc. If a heredoc is unavoidable, use a single-quoted delimiter: `<<'EOF'`.

After publication, verify that GitHub stored literal Markdown. If shell output or credentials appear, immediately delete/replace the affected comment, stop work, and tell the user to rotate exposed credentials.

## Scope Check

Before investigation, state the proposed scope in three short bullets:

- **Required outcome:** the behavior explicitly requested by the issue or spec.
- **Non-goals:** adjacent features, refactors, generalization, cleanup, and future-proofing that are not required for that outcome.
- **Simplest likely approach:** the smallest change expected to deliver the required outcome, using existing patterns where possible.

Treat the issue or spec as a strict boundary. Every task, changed file, dependency, test, and design decision must map to an explicit requirement or a demonstrated correctness need. Do not infer new product requirements or add infrastructure, abstractions, migrations, or extra capabilities merely because they may be useful later. Record relevant ideas that are not necessary under **Out of scope** rather than adding them to the plan.

If the scope is ambiguous, or investigation shows the simplest approach would materially exceed it, stop and ask the user to clarify or approve the expansion before planning it.

If the task spans multiple independent subsystems, suggest breaking it into
separate plans — one per subsystem. Each plan should produce working,
testable software on its own.

## Simplicity Gate

Before defining tasks, make the case for the smallest viable design:

1. Explain the proposed design in at most two plain-English sentences.
2. List every new moving part—file, abstraction, dependency, state model,
   configuration option, or extension point—and the current requirement or
   demonstrated correctness need that justifies it.
3. Name the simpler direct alternative where one exists, and explain why it is
   insufficient.
4. State what is intentionally not being built. Put speculative future ideas
   under **Out of scope**, not into the plan.

A design that cannot be explained simply or justify its moving parts is not
ready to plan. Simplify it or ask the user to approve the necessary complexity.

## Step 1: Preflight Investigation & Ponytail Ladder

Before planning or writing anything, run the Ponytail decision ladder to establish the minimal correct implementation and verify assumptions against the live codebase.

1. **Verify Workspace State**:
   - Run the build/tests (e.g. `npm test`) to ensure a clean starting state.
   - Confirm git status (`git status --porcelain`) is clean.
2. **Apply the Ponytail Ladder**:
   - **Is it necessary?** Does this feature actually need code, or can it be config/data?
   - **stdlib/runtime**: Can built-ins cover this?
   - **Framework**: Is there a native framework feature?
   - **Dependencies**: Do installed dependencies cover this? (Check package files)
   - **Minimal implementation**: What is the smallest possible implementation composing what exists?
3. **Verify Codebase Assumptions**:
   - Scan the codebase to ensure assumed class names, file paths, exports, and schemas exist.
4. **Identify What We're Not Building**:
   - Explicitly list features or complexity eliminated by the ladder.

## Step 2: Map the File Structure

Before defining tasks, map out which files will be created or modified and
what each is responsible for. Decomposition decisions get locked in here.

- Each file should have one clear responsibility
- Files that change together should live together — split by responsibility,
  not by technical layer
- In existing codebases, follow established patterns
- Prefer cohesive, easy-to-navigate files; do not split a cohesive change into
  extra files merely to make them smaller

## Step 3: Right-size the Tasks

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate.

- Fold setup, configuration, and scaffolding into the task whose deliverable
  needs them
- Split only where a reviewer could meaningfully reject one task while
  approving its neighbour
- Each task ends with an independently testable deliverable
- Do not split a cohesive implementation merely to create more tasks or commits
- Specify tests for distinct required behaviours; do not add speculative cases
  that do not follow from the requirements or the system's real boundaries

## Step 4: Write the Plan

### Document Header

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

## Simplicity Rationale

**Plain-language design:** [Explain the design in at most two sentences.]

**New moving parts:** [For each new file, abstraction, dependency, state model, configuration option, or extension point: its present-day justification.]

**Intentionally omitted:** [The complexity and speculative capabilities excluded from this plan.]

**Tech Stack:** [Key technologies and libraries]

## Adversarial Audit & Security

[List key edge cases, security hazards, sanitization needs, or potential race conditions identified, and how they are handled in this plan.]

## Global Constraints

[Project-wide requirements — version floors, dependency limits, naming rules,
platform requirements — one line each. Every task implicitly includes this
section.]

---
```

### Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts`
- Test: `tests/exact/path/to/test.ts`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks or existing modules — exact signatures and types]
- Produces: [what later tasks rely on — exact function names, parameter and return types]

**Key Changes & Logic:**
- [Bullet points describing the concrete logic, algorithmic changes, or state updates]
- [Type definitions or function signatures where relevant; omit complete method bodies]

**Test Plan & Coverage:**
- [Target test file: `tests/exact/path/to/test.ts`]
- [Specific scenario 1: Input/condition -> Expected outcome]
- [Specific scenario 2: Edge case or boundary condition -> Expected behavior]
- [Specific scenario 3: Error state or failure mode -> Expected handling/rejection]

**Verification & Commit:**
- Run: `npm test -- tests/exact/path/to/test.ts`
- Commit message: `feat(scope): concise description of deliverable`
````

## No Placeholders and No Code Dumps

Every task must contain clear architectural contracts and behavioral specs an engineer needs.

Avoid vague plan failures:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "handle edge cases" (without naming specific conditions and expected behavior)
- "Write tests for the above" (without naming concrete test scenarios, inputs, and expected outcomes)
- "Similar to Task N" (state the specific contract — tasks may be read or reviewed independently)
- Referencing types or functions that are neither existing nor defined in a preceding task

Avoid premature code dumps:
- Do not write full test function bodies or large fixture/mock data payloads in the plan.
- Do not draft complete production method bodies in the plan.
- Focus on interfaces, signatures, algorithms, and test coverage requirements. Code belongs in the implementation phase under compiler and linter enforcement.

## Step 5: Self-Review & Verification

After writing the complete plan, check it against the original spec and the live codebase.

1. **Spec coverage** — can you point to a task for each requirement? List gaps.
2. **Placeholder scan** — search for any of the patterns listed above. Fix them.
3. **Codebase alignment** — double-check that every modified file, function signature, or imported module exists or is explicitly created in a preceding task.
4. **Type consistency** — do types, method signatures, and property names match
   across tasks? A function called `clearLayers()` in Task 3 but
   `clearAllLayers()` in Task 7 is a bug.
5. **Simplicity** — can the design be explained in its two-sentence summary,
   and does every new moving part have a present-day justification? Remove or
   explicitly defer anything that does not.

Fix issues inline. If a spec requirement has no task, add the task.

## Step 6: Review the Plan with the User

Do **not** write the plan to GitHub yet. After self-review, walk the user
through the plan slowly, one task at a time, so they can validate the approach,
ask questions, and request changes before it becomes canonical.

1. Briefly present the document header, file map, and task list.
2. Present Task 1 in full, explain its deliverable and dependencies, then stop
   and ask for feedback. Do not continue to the next task until the user has
   had an opportunity to respond.
3. Repeat for every remaining task. Incorporate agreed changes into the plan
   before moving on; keep interfaces, tests, and task boundaries consistent
   when a change affects multiple tasks.
4. After the final task, show or summarize the revised complete plan and ask
   for explicit approval to persist it. Approval must be unambiguous (for
   example, "approve the plan" or "post it to GitHub"). Questions, silence,
   or approval of an individual task are not approval to publish the plan.
5. If the user requests changes, revise the plan and repeat the affected parts
   of the walkthrough and final approval request.

## Step 7: Persist the Approved Plan on GitHub

Only after the user explicitly approves the complete plan:

1. Verify there is a GitHub remote: `gh repo view --json nameWithOwner` — if it fails, stop and tell the user.
2. Determine the destination:
   - **Existing implementation/feature/bug issue:** when the user supplied an issue number, or the plan is clearly for an existing issue, that issue is the canonical destination. Do **not** create a separate `[PLAN]` issue. Post the full final plan as a new comment on that issue:
     ```
     gh issue comment <issue-number> --body-file /tmp/<repository>-issue-<issue-number>-plan.md
     ```
     Keep the issue body as a concise problem/scope summary with a link to the canonical plan comment; do not leave a second, less precise plan in the body.
   - **No existing issue:** create one standalone plan issue:
     ```
     gh issue create --title "[PLAN] <feature-name>" --body-file /tmp/<repository>-plan.md
     ```
3. Before posting to an existing issue, inspect its comments for earlier implementation plans:
   ```
   gh api repos/<owner>/<repo>/issues/<issue-number>/comments --paginate
   ```
   Remove superseded plan comments so there is exactly one canonical implementation plan. Delete only comments authored by the current user/agent; if an obsolete plan comment belongs to someone else, ask the user before deleting it.
4. After posting, verify the issue has one canonical plan and no obsolete plan comments.
5. Label the issue `ready-for-impl` so it's easy to find issues with a fully formed plan versus ones still needing investigation:
   ```
   gh issue edit <issue-number> --add-label ready-for-impl
   ```
   If the label doesn't exist yet in the repo, create it first:
   ```
   gh label create ready-for-impl --description "Has a fully formed implementation plan, ready for automated/manual implementation" --color 0E8A16
   ```
6. Tell the user the issue URL and ask how they want to proceed: inline execution in this session, or they'll drive it themselves.
