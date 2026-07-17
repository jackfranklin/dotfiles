# Pi permissions extension

Risk-based safety gate for Pi tool calls.

The extension gates `bash`, `read`, `write`, and `edit` calls using rules in:

```txt
~/.pi/agent/permissions.json
```

In this dotfiles repo that file is symlinked from:

```txt
pi/permissions.json
```

## Policy model

This is a guardrail, not a sandbox. It is designed to avoid obvious stupid / bad /
dangerous commands while keeping normal coding-agent commands low-friction.

Tool calls are classified in this order:

1. hardcoded dangerous bash patterns => block
2. configured `block` globs => block
3. configured `safe` globs => allow
4. configured `prompt` globs => prompt in the main UI, block in headless/subagent contexts
5. write redirections to real files => prompt/block
6. `write` / `edit` outside the current working directory or into sensitive system paths => prompt/block
7. everything else => allow

So the config mainly lists risky and blocked cases; it does **not** need a huge list
of allowed commands like `ls`, `rg`, `git status`, etc.

## Config format

Entries use a tool wrapper plus a simple glob:

```json
{
  "safe": ["Bash(npm install --package-lock-only)"],
  "prompt": ["Bash(rm *)", "Bash(git reset --hard*)"],
  "block": ["Bash(sudo*)", "Bash(mkfs*)"]
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

Bash commands are split into independently executed segments on shell control
operators such as:

- `&&`
- `||`
- `;`
- `|`
- `&`
- newlines

For example:

```bash
git status && npm install && rg foo
```

Only the `npm install` segment needs approval if `Bash(npm install*)` is in
`prompt`.

## Hardcoded blocks

Some commands are blocked even if they are not listed in `block`, including:

- privilege escalation: `sudo`, `doas`, `pkexec`, `su`
- disk/device mutation: `mkfs`, `fdisk`, `parted`, `wipefs`, `dd of=/dev/...`
- destructive root/home/current-dir removal such as `rm -rf /`, `rm -rf ~`, `rm -rf .`
- device redirections like `> /dev/sda`
- remote shell piping such as `curl ... | bash` / `wget ... | sh`
- shutdown/reboot/poweroff/halt/init 0
- fork bombs and `kill -9 1`

## Redirections and file tools

Read redirections and benign write redirections to `/dev/null`, `/dev/stdout`,
`/dev/stderr`, and `/dev/fd/*` are allowed.

Write redirections to real files prompt in the main UI and block without UI.
A variable assigned directly from the no-argument form of `mktemp` is treated
as a temporary-file target for later segments in that same bash call, so a
standard create/use/cleanup sequence does not prompt. Reassigning or unsetting
that variable revokes the exception.

`write` and `edit` calls prompt when the path is outside the current working
directory or targets sensitive system locations such as `/etc`, `/usr`, `/var`,
`/dev`, `/proc`, or `/sys`.

## Prompt actions

When a call needs approval, the UI offers:

- `Allow once`
- `Allow always` — saves a `safe` override
- `Ban once`
- `Ban always` — saves a `block` rule

In headless/subagent contexts, anything that would prompt is blocked instead.

## Approval audit log

Every interactive approval dialog is recorded locally in:

```txt
~/.pi/agent/permission-approvals.jsonl
```

The append-only JSONL log records an `approval-request` and its corresponding
`approval-decision` with a shared id, including the working directory,
command/path, risk details, and selected action. A dialog interrupted before a selection still has its
request entry. The file is created with mode `0600`; it is local history and is
not part of the dotfiles symlink.

For example, inspect it with:

```bash
jq -s . ~/.pi/agent/permission-approvals.jsonl
```

## Tests

Run with Node's built-in test runner:

```bash
node --test pi/extensions/permissions/*.test.ts
```
