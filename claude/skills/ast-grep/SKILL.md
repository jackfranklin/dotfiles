---
name: ast-grep
description: Use when searching for multiline code patterns, AST node structures, API usages, or function signatures where plain regex/grep fails due to whitespace, linebreaks, or comment noise.
---

Use `ast-grep` (CLI binary `ast-grep` or `sg`) for structural, syntax-tree aware code search.

## Decision Boundary: ast-grep vs ripgrep

- **Use `ripgrep` (`rg`) when:**
  - Searching for exact literal strings, comments, import paths, or single-line identifiers.
  - Searching non-AST/plain text files (markdown, JSON, YAML, config files).

- **Use `ast-grep` when:**
  - Matching multiline code blocks, call signatures, or nested control structures.
  - Searching for code pattern equivalence regardless of formatting, spacing, or line breaks.
  - Filtering out false positives in comments or string literals.
  - Searching for functions called with specific argument patterns (e.g. callback functions, specific parameter types).

## CLI Command Usage

Execute searches:

```bash
ast-grep run --pattern '<PATTERN>' --lang <LANG> <DIR>
```

Or short alias:

```bash
sg run -p '<PATTERN>' -l <LANG> <DIR>
```

### Common Language Identifiers (`-l` / `--lang`)
`ts`, `tsx`, `js`, `jsx`, `python`, `go`, `rust`, `cpp`, `c`, `html`, `css`.

## Pattern Syntax Cheat Sheet

| Syntax | Description | Example |
| :--- | :--- | :--- |
| `$VAR` | Single AST node variable | `foo($A, $B)` |
| `$$$ARGS` | Zero or more AST nodes (spread metavariable) | `console.log($$$ARGS)` |
| `___` | Wildcard single node (anonymous) | `if (___) { $$$ }` |

### Syntax Examples

1. **Find all function calls with callback as last argument:**
   ```bash
   ast-grep run -p '$FUNC($$$ARGS, ($$$PARAMS) => { $$$BODY })' -l ts .
   ```

2. **Find specific JSX/TSX element usage:**
   ```bash
   ast-grep run -p '<Button onClick={$HANDLER}>$$$CHILDREN</Button>' -l tsx .
   ```

3. **Find error logging calls:**
   ```bash
   ast-grep run -p 'logger.error($$$ARGS)' -l ts src/
   ```

4. **Find async functions without try-catch:**
   ```bash
   ast-grep run -p 'async function $NAME($$$ARGS) { $$$BODY }' -l ts src/
   ```
