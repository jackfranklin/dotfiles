---
name: write-plan
description: >
  Write a comprehensive, no-placeholder implementation plan as a series of
  bite-sized tasks, each with exact file paths, real code, TDD steps, and
  commit instructions. Saves to .jai/detailed-plans/. Inspired by
  obra/superpowers writing-plans skill. Use after preflight has established
  what to build.
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

## Step 3: Write the Plan Document

Save to `.jai/detailed-plans/YYYY-MM-DD-<feature-name>.md`.

### Document Header

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

**Tech Stack:** [Key technologies and libraries]

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

## Step 5: Handoff

After saving, tell the user the plan path and ask how they want to proceed:
inline execution in this session, or they'll drive it themselves.
