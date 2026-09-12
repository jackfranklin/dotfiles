# ast-grep Cheat Sheet

Structural, syntax-tree aware code search via `ast-grep` (or `sg`).

## When to use vs ripgrep
- **Use `ripgrep` (`rg`)**: literal strings, comments, single-line tokens, non-AST/plain text files (markdown, JSON, YAML).
- **Use `ast-grep` (`sg`)**: multiline code blocks, call signatures, nested control structures, syntax pattern matching independent of whitespace or formatting.

## CLI Usage
```bash
ast-grep run --pattern '<PATTERN>' --lang <LANG> <DIR>
# Or short form:
sg run -p '<PATTERN>' -l <LANG> <DIR>
```

### Supported Languages (`-l`)
`ts`, `tsx`, `js`, `jsx`, `python`, `go`, `rust`, `cpp`, `c`, `html`, `css`.

## Pattern Syntax
- `$VAR`: Single AST node variable (e.g. `foo($A, $B)`)
- `$$$ARGS`: Zero or more AST nodes (spread metavariable) (e.g. `console.log($$$ARGS)`)
- `___`: Wildcard single node (e.g. `if (___) { $$$ }`)

## Examples
1. **Find all function calls with callback as last argument:**
   ```bash
   ast-grep run -p '$FUNC($$$ARGS, ($$$PARAMS) => { $$$BODY })' -l ts .
   ```
2. **Find JSX/TSX element usage:**
   ```bash
   ast-grep run -p '<Button onClick={$HANDLER}>$$$CHILDREN</Button>' -l tsx .
   ```
3. **Find error logging calls:**
   ```bash
   ast-grep run -p 'logger.error($$$ARGS)' -l ts src/
   ```
