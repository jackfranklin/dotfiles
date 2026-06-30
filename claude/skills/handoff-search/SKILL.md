---
disable-model-invocation: true
name: handoff-search
description: Find and list plans and handoffs saved as GitHub Issues in the current repo to resume work.
---

To find a handoff or plan:

1. Verify there is a GitHub remote for the current repo. Run `gh repo view --json nameWithOwner` — if it fails, stop and tell the user there is no GitHub remote.
2. Search for open issues with `[HANDOFF]` and `[PLAN]` prefixes:
   ```
   gh issue list --search "[HANDOFF] OR [PLAN]" --state open --json number,title,url,body
   ```
3. Present the results categorized under two sections:
   - **Active Plans** (title starts with `[PLAN]`)
   - **Recent Handoffs** (title starts with `[HANDOFF]`)
   Include the issue number, title, URL, and the **Summary** line from the body for each.
4. If the user or context implies a specific topic, recommend the most relevant issue.
5. Once the correct issue is identified, read its full body with `gh issue view <number> --json body` to load the context.
