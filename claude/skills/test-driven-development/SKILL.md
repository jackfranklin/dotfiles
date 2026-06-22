---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

## When to Use

**Always:**
- New features
- Bug fixes
- Refactoring (ensure test suite remains green)
- Behavior changes

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over. Do not keep it as reference. Delete means delete.

## Testability Blockers & Guardrails

- **Flag and Escalate**: If you cannot figure out how to write a test using the defined architecture in the repository, do not guess or get stuck. Stop immediately, flag it to the user, and ask for advice.
- **Time Boxing**: Do not spend more than 10-15 minutes trying to figure out test setups, infrastructure, or testing logic. If it takes longer, escalate.
- **No Large Test Refactors**: Do not make large infrastructure changes or modify multiple production/helper files solely to make a test work. Keep test helper code local and self-contained unless advised otherwise by the user.

## Red-Green-Refactor Cycle

1. **RED - Write Failing Test**:
   - Write one minimal test showing what should happen.
   - Run the test and confirm it fails (not compile errors, but test failure) with the expected message.
   - If the test passes, it is not testing new behavior. Fix the test.
2. **GREEN - Minimal Code**:
   - Write the simplest code to pass the test. Do not add extra features or over-engineer.
   - Run the test and confirm it passes.
3. **REFACTOR - Clean Up**:
   - Remove duplication, improve names, extract helpers.
   - Run tests to ensure they stay green.

## Test Guidelines

- Avoid testing mocks. Test real behavior.
- Keep tests isolated. One test should not depend on the state of another.
- Delete temporary tests or mock connection files once the implementation is complete.
