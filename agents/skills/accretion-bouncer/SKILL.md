---
disable-model-invocation: true
name: accretion-bouncer
description: Audit recent changes or a branch diff for additive code bloat using the accretion-bouncer subagent.
---

# Accretion Bouncer

## Steps

1. **Identify the Target Diff**: Determine the target changes from the user prompt (uncommitted diff with `git diff HEAD`, latest commit with `git show --format= HEAD`, or branch diff against parent or base branch with `git diff <base>...HEAD`). If untracked files are in scope, run `git add -N -- <files>` so they appear in the diff without staging their contents.
   *Completion criterion*: The exact Git review range and list of modified files are identified and non-empty.

2. **Dispatch `accretion-bouncer`**: Spawn the `accretion-bouncer` subagent {{#claude}}(using the Agent tool with `subagent_type: "accretion-bouncer"`){{/claude}}{{#pi}}(using the `subagent` tool with `agent: "accretion-bouncer"`){{/pi}}{{#antigravity}}(using `invoke_subagent` with `TypeName: "self"` and `Role: "accretion-bouncer"`){{/antigravity}}, passing the exact Git review range, the repository/worktree root path, the list of modified files, and a 1–2 sentence summary of the change's goal.
   *Completion criterion*: `accretion-bouncer` returns its findings or the null action.

3. **Verify & Present Reframings**: Fact-check each finding against live source files. Drop any finding that breaks a verified caller contract or type constraint. Present the verified report inline in chat (never as an artifact file): either the null action, or numbered reframings (`1..N`) with `Target & Cost`, `Why It Is Redundant`, and `Replacement`. Do not edit repository files during `/accretion-bouncer`; end with a plain-text prompt asking whether to apply specific numbered reframings or step through them with `/one-by-one`.
   *Completion criterion*: Verified findings (or the null action) are presented inline in chat with zero repository file edits.
