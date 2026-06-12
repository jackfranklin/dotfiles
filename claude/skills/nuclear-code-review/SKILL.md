---
name: nuclear-code-review
description: Aggressive maintainability review focused on structural simplification, deleting complexity, and meticulous code reviews. Activate this skill ANY TIME the user asks for a code review or when you need to perform a senior-level, thorough analysis of code changes.
---

# Nuclear Code Review

Harsh, expert code review focused on implementation quality, aggressive simplification, and long-term maintainability. **Be ambitious.** Do not merely identify local cleanup opportunities; actively search for "code judo" moves that make the implementation dramatically simpler and more elegant.

## Core Principles

1.  **Code Judo**: Actively look for restructurings that delete complexity rather than rearranging it. Reframe the problem so branches, helpers, or layers disappear entirely.
2.  **Zero Spaghetti**: Ban ad-hoc conditionals and scattered special cases in unrelated flows. Push logic into dedicated abstractions or state machines.
3.  **Direct & Boring**: Prefer explicit, legible code over hacky, magical, or thin abstractions that add indirection without value.
4.  **Strict Boundaries**: Enforce clean type contracts. Flag unnecessary optionality, `any`, `unknown`, or excessive casting.
5.  **Canonical Home**: Put logic in the correct layer and reuse existing utilities instead of building bespoke ones.

## Workflow

1.  **Read Commit Message:** Start by checking for and reading the commit message on the branch (e.g., using `git log` or similar VCS commands) to gain context on the changes. If there are no commits yet (e.g., work is unstaged/staged but not committed), it is fine to proceed without one.
2.  **Identify Changes:** Check for unstaged or staged (uncommitted) changes. If present, review them. If not, review the last commit. If unsure, ask the user.
3.  **Review Individually:** Process each changed file one by one.
4.  **Gather Full Context:** For each file, get its specific code diff. Crucially, to understand the full impact of a change, use tools to read other, unchanged files in the repository as needed (e.g., to see a function definition, a class signature, or a constant that is referenced in the changed code).
5.  **Static Review Only:** Do not build the project or run tests. Assume that the code compiles successfully and all tests pass. Focus your review entirely on static analysis (logic, design patterns, readability, maintainability, type safety, correctness).

## Review Checklist & Approval Bar

Analyze the changes against the following checklist. Do not approve merely because the code works. Reject the change if any of the following apply:

1.  **Plausible Simplification Missed:** A "code judo" move was missed that could make the implementation dramatically simpler.
2.  **Tangled Flow:** It introduces ad-hoc branching or tangles an existing flow.
3.  **Scattered Logic:** It scatters feature-specific logic across shared modules.
4.  **Weak Abstractions:** It adds an abstraction that does not earn its keep.
5.  **UI & Front-End Red Flags:**
    - **UI Components:** Check for unused CSS variables/classes, and missing encapsulation or visibility modifiers (e.g., `readonly` or `private`) on class members.
    - **Build Files:** Check for missing or unnecessary dependencies, and incorrect file paths.
    - **Resource Management (Critical):** Verify explicit cleanup of timers (`setTimeout`, `setInterval`), event listeners, subscriptions, etc., in appropriate lifecycle methods (e.g., `disconnectedCallback`, `ngOnDestroy`, `finally`) to prevent leaks.
    - **Accessibility (a11y):** For UI changes, verify semantic HTML, ARIA attributes, and keyboard operability.
6.  **Asynchronicity:** Incorrect usage of `async`/`await`, Promises, or UI framework async helpers. Potential race conditions or missing cancellation.
7.  **Error Handling:** Missing or weak error handling for expected failures (network, API, file operations).
8.  **Testability, Suspicious Deletions & Bloat:**
    - Examine test changes for deleted assertions (`assert`, `expect`), setup/teardown deletion, or test cases removed without corresponding feature removal.
    - **Test Bloat & Complexity:** Flag newly added unit test files or individual test cases that are excessively long (e.g., adding hundreds of lines of code, or massive test cases on their own), suggesting they be refactored, parameterized, or split into smaller, more focused tests.
9.  **Code Style, Readability & Naming:** Vague names (`data`, `result`), inconsistent casing, negative boolean names (`isNotLoading`), or missing comments for complex logic.

