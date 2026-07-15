---
disable-model-invocation: true
name: resolving-merge-conflicts
description: "Use when you need to resolve an in-progress git merge/rebase conflict."
---

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`. If you are unsure of the correct resolution, stop and ask the user for clarification.

4. **Verify conflict markers.** Before staging any resolved file, explicitly search it to ensure all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) have been removed.

5. Discover the project's **automated checks** and run them. Build the project first, then run typecheck, tests, and format. Fix anything the merge broke.

6. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.
