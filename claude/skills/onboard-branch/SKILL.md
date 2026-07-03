---
disable-model-invocation: true
name: onboard-branch
description: >
  Onboard onto the current Git branch. Explores recent commits, diffs,
  uncommitted changes, and handoffs, then summarizes the state and asks
  clarifying questions to get up to speed.
---

# Onboard Branch

Use this skill when you want a fresh agent to get up to speed on the current Git branch and pick up work where a previous agent or session left off.

## IMPORTANT: DO NOT run any tests or compiler.

Assume that the project is valid. You will be told if anything is failing.

## Step 1: Gather Git Context

Run the following commands to understand the current Git state:

1. **Current Branch**:
   ```bash
   git branch --show-current
   ```
2. **Recent Commits**: Find commits unique to this branch. Attempt to identify the base branch (`origin/main`, `origin/master`, `main`, or `master`) and log the commits:

   ```bash
   # Find merge base and log commits unique to branch; fallback to last 5 commits if range is invalid
   git log --oneline --graph $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null || git log --oneline --graph -n 5
   ```

   _Note: If the commit history is tangled, no base branch is found, or it is unclear which commits represent the current work, ask the user directly._

3. **Uncommitted Changes Status**:
   ```bash
   git status --porcelain
   ```
4. **Capture Full Diff**: Get the diff of all changes (committed on this branch + uncommitted) against the base branch:

   ```bash
   # Resolve the base commit
   BASE_COMMIT=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null || git merge-base HEAD master 2>/dev/null || git rev-parse HEAD~1 2>/dev/null || echo HEAD)

   # 1. Run stats first to check scale of changes
   git diff --stat $BASE_COMMIT

   # 2. Capture diff. If --stat shows a large diff (e.g. > 500 lines or > 10 files),
   # check files of interest individually instead of dumping the whole diff.
   git diff $BASE_COMMIT
   ```

## Step 2: Look for Handoffs or Active Plans

Check if there are any active plans or handoffs in the project root that might provide high-level context:

1. Locate the Git root and list files:
   ```bash
   GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
   ls -la "$GIT_ROOT/.todos/" 2>/dev/null || true
   ```
2. If any files exist, read the most recently modified ones.

## Step 3: Analyze and Formulate Questions

Examine the commits, diffs, and documents to construct:

1. **Goal Summary**: A clear statement of what this branch is trying to achieve.
2. **Work Done So Far**: A list of changes already made (based on commits and diffs).
3. **Current State**: Where the code stands, including any obvious compilation errors, lint issues, or incomplete sections.
4. **Comprehension Gaps & Questions**: List any questions you need answered to continue work, such as:
   - What are the immediate next steps?
   - Are there specific design patterns or decisions to keep in mind?
   - Are there any blocker issues or unresolved questions?

## Step 5: Present to the User

Present the summary to the user. Ask them to answer the clarifying questions and confirm if they are ready for you to proceed (and with what task, e.g., continuing development, code review, etc.).
