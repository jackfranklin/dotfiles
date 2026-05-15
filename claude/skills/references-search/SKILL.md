---
name: references-search
description: Search jackfranklin/references (personal technical reference docs) for files relevant to the current task. Use when you need a reference guide on a library, API, or tool, or when the user invokes /references-search with search keywords as $ARGUMENTS.
---

# References Search

Search the personal technical reference library at `jackfranklin/references` and return the content of matching files.

## Step 1: Set the repo path

The repo always lives at `$HOME/.claude/repos/references`. Use the literal expanded path in every Bash command (e.g. `/root/.claude/repos/references` in the remote environment, or `~/.claude/repos/references` locally) since shell variables don't persist between tool calls. Expand `$HOME` before running any command.

## Step 2: Ensure the repo is present and fresh

First check if it exists:

```bash
ls $HOME/.claude/repos/references/.git 2>/dev/null && echo "exists" || echo "missing"
```

**If missing:** clone it fresh:

```bash
mkdir -p $HOME/.claude/repos
gh repo clone jackfranklin/references $HOME/.claude/repos/references
```

**If it exists:** fetch from origin and compare local HEAD to upstream to decide if a pull is needed:

```bash
git -C $HOME/.claude/repos/references fetch origin main --quiet
git -C $HOME/.claude/repos/references rev-parse HEAD
git -C $HOME/.claude/repos/references rev-parse origin/main
```

If the two hashes differ, the local branch is behind — pull it:

```bash
git -C $HOME/.claude/repos/references pull --ff-only origin main
```

If the hashes match, the repo is already up to date — skip the pull.

## Step 3: Parse search terms

The user provided: `$ARGUMENTS`

Split into individual search terms. If `$ARGUMENTS` is empty, infer relevant keywords from the current task or conversation context (e.g. the library, API, or technology being discussed).

## Step 4: Search for matching files

Run two searches and deduplicate the results.

**Search A — filename match:**

```bash
ls $HOME/.claude/repos/references/*.md 2>/dev/null
```

A file matches if any search term appears in its name after treating hyphens as word separators. For example, "speech" matches `browser-speech-to-text.md`; "genai" matches `google-genai.md`.

**Search B — content grep (case-insensitive, filenames only):**

For each search term:

```bash
grep -ril "TERM" $HOME/.claude/repos/references/
```

Combine results from A and B, removing duplicates. Keep only `.md` files.

If more than 4 files matched, prefer files that matched on both filename and content, then filename-only, then content-only. Read the top 4.

## Step 5: Read matched files

Use the Read tool to read each matched file in full. Reference files are intentionally small and self-contained — always read the complete file, never truncate.

## Step 6: Fallback — no matches found

If Step 4 returned nothing, list all available reference files:

```bash
ls $HOME/.claude/repos/references/*.md 2>/dev/null
```

Display as a bullet list (strip the path prefix and `.md` suffix for readability) and ask the user which one to read, or pick the most likely candidate based on context.

## Step 7: Return the reference content

Explain which file(s) you found and why they're relevant, then present the full reference content in a way that directly addresses the current task. Do not summarize or truncate — complete, accurate reference material is the deliverable.

If multiple files matched, separate their contents with a heading per file.
