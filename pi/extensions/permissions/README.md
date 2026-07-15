# Pi permissions extension

Custom permission gate for Pi tool calls.

The extension gates `bash`, `read`, `write`, and `edit` calls using allow/deny patterns in:

```txt
~/.pi/agent/permissions.json
```

In this dotfiles repo that file is symlinked from:

```txt
pi/permissions.json
```

## Pattern format

Entries use a tool wrapper plus a simple glob:

```json
{
  "allow": ["Read(*)", "Bash(git status *)"],
  "deny": ["Bash(rm -rf *)"]
}
```

Supported tools:

- `Bash(...)`
- `Read(...)`
- `Write(...)`
- `Edit(...)`

Glob support is intentionally small:

- `*` matches any run of characters
- `?` matches exactly one character
- patterns are anchored, so `Bash(sort *)` does **not** match bare `sort`

## Bash matching

Bash commands are split into independently executed segments on shell control operators such as:

- `&&`
- `||`
- `;`
- `|`
- `&`
- newlines

Every segment must be allowlisted for the command to run without prompting. Deny rules win over allow rules.

For example:

```bash
find pi -maxdepth 3 -type f -print | sort
```

requires both:

```json
"Bash(find *)",
"Bash(sort)"
```

If a segment is not allowlisted, the prompt shows the exact unmatched segment.

## Redirections

Read redirections and benign write redirections to `/dev/null`, `/dev/stdout`, `/dev/stderr`, and `/dev/fd/*` are allowed to be covered by the command pattern.

Write redirections to real files always prompt, even when the command itself is allowlisted.

## Prompt actions

When a call is not covered, the UI offers:

- `Allow once`
- `Allow always`
- `Ban once`
- `Ban always`

The `always` choices open an editor with a suggested pattern that can be adjusted before saving.

If the only issue is a missing bare command and the args form already exists, the prompt offers a targeted fix. For example, if `Bash(sort *)` exists but bare `sort` is blocked, the prompt can add:

```json
"Bash(sort)"
```

without changing the meaning of `Bash(sort *)` globally.

## Tests

Run with Node's built-in test runner:

```bash
node --test pi/extensions/permissions/*.test.ts
```
