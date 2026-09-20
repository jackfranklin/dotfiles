---
name: resolve-merge-conflict
description: "Use when you need to resolve an in-progress git merge/rebase conflict."
---

1. **Confirm authority and see the current state.** Check the merge/rebase state, Git history, and conflicting files. If the user explicitly asked to resolve the conflicts, that authorizes resolution. If the conflict was only discovered while doing another task, inspect it without editing and ask for confirmation before resolving it.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Never `--abort` a user's merge/rebase without explicit authorization. If you are unsure of the correct resolution, stop and ask the user for clarification.

4. **Verify conflict markers.** Before staging any resolved file, explicitly search it to ensure all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) have been removed.

5. Discover the project's **automated checks**. Run only checks that do not modify tracked files. If a check may format or otherwise write files, or a failure requires changes beyond the resolved conflict files, ask the user before running it or making those changes.

6. **Finish only the intended merge/rebase.** Stage only the resolved conflict files. If unrelated staged or modified files are present, stop and ask which files to include. Commit the resolution, or continue the rebase process until all commits are rebased.
