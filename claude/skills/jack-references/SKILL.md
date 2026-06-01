---
name: jack-references
description: Manage Jack's personal technical reference library at ~/git/references. Use for searching/reading existing references, or adding new ones. Invoke with /jack-references and optional keywords to search, or when the user wants to save a new reference guide. PROACTIVELY suggest saving a new reference whenever the conversation involves figuring out how a library, API, or tool works — especially after debugging, reading docs, or solving a non-obvious integration problem. A good prompt: "Want me to save this as a reference for next time?"
---

# Jack References

Personal technical reference library at `~/git/references`. Each file is a focused Markdown cheatsheet for a library, API, or tool.

## Shared Setup: Resolve Repo Path

First, resolve the absolute path to the references repo:

```bash
echo $HOME/git/references
```

Use the output of this command (e.g. `/home/jack/git/references`) as the literal path for **all subsequent commands** in this skill. Never use `$HOME` again after this step — always substitute the resolved absolute path.

## Shared Setup: Clone/Pull

Check if the repo exists:

```bash
ls $HOME/git/references/.git 2>/dev/null && echo "exists" || echo "missing"
```

**If missing:** clone it:

```bash
mkdir -p $HOME/git
gh repo clone jackfranklin/references $HOME/git/references
```

**If it exists:** fetch and check if a pull is needed:

```bash
git -C $HOME/git/references fetch origin main --quiet
git -C $HOME/git/references rev-parse HEAD
git -C $HOME/git/references rev-parse origin/main
```

If the hashes differ, pull:

```bash
git -C $HOME/git/references pull --ff-only origin main
```

If they match, skip the pull.

---

## Searching and Reading References

### Parse search terms

The user provided: `$ARGUMENTS`

Split into individual search terms. If `$ARGUMENTS` is empty, infer relevant keywords from the current task or conversation context (e.g. the library, API, or technology being discussed).

### Search for matching files

Run two searches and deduplicate.

**Search A — filename match:**

```bash
ls $HOME/git/references/*.md 2>/dev/null
```

A file matches if any search term appears in its name after treating hyphens as word separators. For example, "speech" matches `browser-speech-to-text.md`; "genai" matches `google-genai.md`.

**Search B — content grep (case-insensitive, filenames only):**

For each search term:

```bash
grep -ril "TERM" $HOME/git/references/
```

Combine results from A and B, removing duplicates. Keep only `.md` files.

If more than 4 files matched, prefer files that matched on both filename and content, then filename-only, then content-only. Read the top 4.

### Read matched files

Use the Read tool to read each matched file in full. Reference files are intentionally small and self-contained — always read the complete file, never truncate.

### Fallback — no matches found

If the search returned nothing, list all available reference files:

```bash
ls $HOME/git/references/*.md 2>/dev/null
```

Display as a bullet list (strip the path prefix and `.md` suffix for readability) and ask the user which one to read, or pick the most likely candidate based on context.

### Return the reference content

Explain which file(s) you found and why they're relevant, then present the full reference content in a way that directly addresses the current task. Do not summarize or truncate — complete, accurate reference material is the deliverable.

If multiple files matched, separate their contents with a heading per file.

---

## Adding a New Reference

Use this when the user wants to save a new reference guide, or when you've just figured out how something works and it's worth capturing for future use.

### 1. Determine the filename

Use lowercase kebab-case based on the topic: `<technology-or-topic>.md`. Examples: `openai-responses-api.md`, `deno-kv.md`, `css-container-queries.md`.

Check it doesn't already exist:

```bash
ls $HOME/git/references/<proposed-name>.md 2>/dev/null && echo "exists" || echo "new"
```

If a file already exists for this topic, offer to update it instead of creating a duplicate.

### 2. Write the file

Reference files follow this structure:

```markdown
# <Title>

Brief one-line description of what this is.

## Key concepts / API

...focused, practical content...

## Examples

...real usage examples...

## Gotchas / notes

...anything non-obvious...
```

Keep it dense and practical — these are personal cheatsheets, not tutorials. No padding.

Use the Write tool to create `$HOME/git/references/<filename>.md`.

### 3. Commit and push

```bash
git -C $HOME/git/references add <filename>.md
git -C $HOME/git/references commit -m "add <filename>"
git -C $HOME/git/references push origin main
```

Confirm the push succeeded and report the filename back to the user.
