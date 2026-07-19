---
disable-model-invocation: true
name: write-plan
description: >
  Write a comprehensive, no-placeholder implementation plan as a series of
  bite-sized tasks, each with exact file paths, real code, TDD steps, and
  commit instructions. Stores plans on the relevant GitHub issue when one
  exists, otherwise creates a standalone [PLAN] issue. Use after preflight
  has established what to build.
---

# Write Plan

Write a rigorous implementation plan assuming the engineer has zero context
about the codebase and will execute tasks in isolation. Every step must
contain everything they need — no references to "fill in later", no vague
instructions, no placeholders.

DRY. YAGNI. TDD. Frequent commits.

## Scope Check

If the task spans multiple independent subsystems, suggest breaking it into
separate plans — one per subsystem. Each plan should produce working,
testable software on its own.

## Step 1: Map the File Structure

Before defining tasks, map out which files will be created or modified and
what each is responsible for. Decomposition decisions get locked in here.

- Each file should have one clear responsibility
- Files that change together should live together — split by responsibility,
  not by technical layer
- In existing codebases, follow established patterns
- Prefer smaller focused files over large ones that do too much

## Step 2: Right-size the Tasks

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate.

- Fold setup, configuration, and scaffolding into the task whose deliverable
  needs them
- Split only where a reviewer could meaningfully reject one task while
  approving its neighbour
- Each task ends with an independently testable deliverable

## Step 3: Write the Plan

### Document Header

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

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
- Modify: `exact/path/to/existing.ts:123-145`
- Test: `tests/exact/path/to/test.ts`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter and
  return types. A task's implementer sees only their own task; this block is
  how they learn the names and types neighbouring tasks use.]

- [ ] **Step 1: Write the failing test**

```typescript
it('specific behaviour', () => {
  const result = fn(input)
  expect(result).toBe(expected)
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- tests/path/test.ts`
Expected: FAIL — "fn is not defined"

- [ ] **Step 3: Write minimal implementation**

```typescript
export function fn(input: string): string {
  return expected
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- tests/path/test.ts`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.ts src/path/file.ts
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are plan
failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "handle edge cases" (without showing how)
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may read tasks out of order)
- Steps that describe what to do without showing how
- References to types or functions not defined in any task

## Step 4: Self-Review

After writing the complete plan, check it against the original spec with
fresh eyes.

1. **Spec coverage** — can you point to a task for each requirement? List gaps.
2. **Placeholder scan** — search for any of the patterns listed above. Fix them.
3. **Type consistency** — do types, method signatures, and property names match
   across tasks? A function called `clearLayers()` in Task 3 but
   `clearAllLayers()` in Task 7 is a bug.

Fix issues inline. If a spec requirement has no task, add the task.

## Step 5: Persist the Plan on GitHub

1. Verify there is a GitHub remote: `gh repo view --json nameWithOwner` — if it fails, stop and tell the user.
2. Determine the destination:
   - **Existing implementation/feature/bug issue:** when the user supplied an issue number, or the plan is clearly for an existing issue, that issue is the canonical destination. Do **not** create a separate `[PLAN]` issue. Post the full final plan as a new comment on that issue:
     ```
     gh issue comment <issue-number> --body "<full plan content>"
     ```
     Keep the issue body as a concise problem/scope summary with a link to the canonical plan comment; do not leave a second, less precise plan in the body.
   - **No existing issue:** create one standalone plan issue:
     ```
     gh issue create --title "[PLAN] <feature-name>" --body "<full plan content>"
     ```
3. Before posting to an existing issue, inspect its comments for earlier implementation plans:
   ```
   gh api repos/<owner>/<repo>/issues/<issue-number>/comments --paginate
   ```
   Remove superseded plan comments so there is exactly one canonical implementation plan. Delete only comments authored by the current user/agent; if an obsolete plan comment belongs to someone else, ask the user before deleting it.
4. After posting, verify the issue has one canonical plan and no obsolete plan comments.
5. Label the issue `ready-for-impl` so it's easy to find issues with a fully formed plan (e.g. for `agent-runner`) versus ones still needing investigation:
   ```
   gh issue edit <issue-number> --add-label ready-for-impl
   ```
   If the label doesn't exist yet in the repo, create it first:
   ```
   gh label create ready-for-impl --description "Has a fully formed implementation plan, ready for automated/manual implementation" --color 0E8A16
   ```
6. Tell the user the issue URL and ask how they want to proceed: inline execution in this session, or they'll drive it themselves.
