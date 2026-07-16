# Pi subagents

Dotfiles-local version of <https://github.com/amosblomqvist/pi-subagents>.

## Agents

| Agent | Tools | Model | Purpose |
| --- | --- | --- | --- |
| `scout` | `read`, `grep`, `find`, `ls` | `openai-codex/gpt-5.5`, low thinking | Fast codebase recon |
| `researcher` | `web_search`, `web_fetch` | `openai-codex/gpt-5.5`, medium thinking | Web research |
| `worker` | `read`, `write`, `edit`, `bash`, `web_search`, `web_fetch`, `subagent` | `openai-codex/gpt-5.5`, medium thinking | Isolated implementation work |

`worker` can only spawn `scout` and `researcher`, so nested delegation stops at depth 2.

## Permissions integration

The upstream package ships `safe_bash`. This version does not. Instead, whenever a child agent gets any of `bash`, `read`, `write`, or `edit`, the child `pi` process is started with this dotfiles permissions extension loaded:

```txt
~/.pi/agent/extensions/permissions/index.ts
```

Because subagents run in JSON/print mode with no UI, permission decisions fail closed:

- `safe` rules allow the call
- `block` rules block the call
- `prompt` rules are blocked because there is no approval UI in the child process

So the main interactive session can still prompt normally, while subagents cannot bypass the policy.

## Usage

Ask the main agent to dispatch a subagent, e.g.

```json
{ "agent": "scout", "task": "Map the Neovim LSP config files and summarize where TypeScript setup happens." }
```

Multiple `subagent` tool calls in one assistant turn run in parallel. `config.json` can set `maxConcurrency`.
