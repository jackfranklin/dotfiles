---
disable-model-invocation: true
name: adversarial-audit
description: Use when planning code changes, writing an implementation plan, or reviewing code to identify potential edge cases, security vulnerabilities, input sanitization issues, race conditions, or boundary values.
---

# Adversarial Audit

## Overview
Perform a rigorous, adversarial review of proposed logic or changes to prevent happy-path bias. Identify security vulnerabilities, parsing anomalies, state desyncs, and boundary errors before writing code.

## When to Use
Use when:
- Planning a code change or drafting an implementation plan.
- Reviewing code diffs for security, correctness, and edge cases.
- Writing parsers, serializers, UI components handling user input, or state transitions.

## Core Pattern
Audit the changes against these four hazard vectors:

1. **Input & Sanitization**
   - **Control Characters**: Are special syntactical characters (e.g. `*`, `_`, `\`, `` ` `` in markdown; `<`, `>`, `&` in HTML) escaped or sanitized?
   - **Injection**: Can scripts, event handlers, or harmful protocol schemes (`javascript:`) be injected?
   - **Encoding**: How are Unicode characters, surrogate pairs, or invalid octets handled?

2. **State & Concurrency**
   - **UI & App Desync**: Can fast user interactions (e.g. double clicks) trigger duplicate requests or corrupt state?
   - **Race Conditions**: How does the system behave if async responses return out of order?
   - **Caching**: Is stale cache cleared or invalidated?

3. **Boundary Values**
   - **Inputs**: Handle null, undefined, empty strings, extremely large payloads, or deeply nested structures safely.
   - **Errors**: Ensure timeouts, network dropouts, or permission rejections fail gracefully instead of crashing or leaking data.

4. **Resource Lifecycle**
   - **Leaks**: Clean up active event listeners, timers, file handles, or network sockets when the component unmounts.

## Common Mistakes
- **Hacky regular expressions**: Using naive regex for HTML/markdown escaping or sanitization instead of standard libraries/well-tested parsers.
- **Silent failure**: Swallowing errors without logging or notifying the user.
- **Happy-path testing**: Writing unit tests that only cover valid inputs.
