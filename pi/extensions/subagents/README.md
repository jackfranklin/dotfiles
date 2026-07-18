# Pi subagents

Dotfiles-local version of <https://github.com/amosblomqvist/pi-subagents>.

This extension registers one Pi tool, `subagent`, that lets the main agent spawn isolated child `pi` processes for focused work. It is optimized for protecting the main context window, not for durable background jobs.

## Architecture and control flow

1. The extension loads agent definitions from `pi/extensions/subagents/agents/*.md` and `maxConcurrency` from `pi/extensions/subagents/config.json`.
2. Pi exposes a single `subagent` tool to the main agent. The tool schema is `{ agent, task, cwd? }`.
3. When called, `index.ts` resolves the current `pi` binary and starts a child process in JSON print mode:
   - `--mode json -p --no-session --no-skills`
   - `--no-extensions`, then only the extensions required by the selected agent's tools
   - `--tools <allowlist>` for exactly the selected agent's declared tools
   - `--models <agent model>` and `--thinking <agent thinking>`
   - `--append-system-prompt <temp prompt file>` containing the agent markdown body
4. The child receives only the supplied task text and working directory. It has no chat history, no main-agent context, and no skills.
5. The parent reads the child's JSON event stream, tracks tool usage/messages/tokens, renders progress in the UI, and returns the child's final assistant text as the tool result.
6. Temporary prompt/task files are created under `/tmp/pi-sub-*` and removed when the child exits.

There is no file handoff protocol. Any handoff is verbal: the child must summarize findings or changes in its final answer.

## Prompts: main guidelines vs child system prompts

There are two separate instruction layers:

- `promptGuidelines` in `index.ts` are injected into the **main agent** when the `subagent` tool is available. They tell the main agent when delegation is appropriate, how to parallelize, and what limits each child has.
- `agents/*.md` frontmatter and body define each **child agent**. The frontmatter controls tools/model/thinking; the markdown body becomes the child's appended system prompt.

Because subagents have no conversation context, the main agent must include all required details in `task`: relevant files, goals, constraints, prior decisions, and expected output.

## Agents and capabilities

| Agent        | Tools                                                                  | Model / thinking                    | Purpose and limits                                                                                                                      |
| ------------ | ---------------------------------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `scout`      | `read`, `grep`, `find`, `ls`                                           | `openai-codex/gpt-5.4-mini`, low    | Read-only codebase recon and architecture mapping. Cannot run shell commands such as `git`/`gh`, cannot edit files, cannot use the web. |
| `researcher` | `web_search`, `web_fetch`                                              | `openai-codex/gpt-5.6-luna`, medium | Public-web research with sourced synthesis. Cannot inspect local files or run commands.                                                 |
| `implementer` | `read`, `write`, `edit`, `bash`, `web_search`, `web_fetch`, `subagent` | `openai-codex/gpt-5.5`, medium      | Implements a discrete, already-planned change. May spawn only `scout` and `researcher` via `subagent_agents: scout, researcher`.         |

Nested delegation stops at depth 2 in practice: the main agent can spawn `implementer`; `implementer` can spawn `scout`/`researcher`; those agents do not have the `subagent` tool.

## Delegation policy

The main agent owns planning, design decisions, and the user-facing final answer.

Use subagents when their separate context or isolation is valuable:

- `scout`: unfamiliar code areas where a compact map is better than loading many files into the main context.
- `researcher`: open-ended external research that would require multiple searches/fetches.
- `implementer`: only after the main agent has a clear plan and needs a discrete, isolated implementation task completed. Its task must include the relevant scope, constraints, and acceptance criteria.

Do not delegate just because a task uses tools. The main agent can read, edit, run tests, use `git`/`gh`, and make decisions itself. Never use `implementer` for general queries, initial investigation, architectural decisions, or writing the plan.

## Parallelism and concurrency

To fan out work, emit multiple independent `subagent` tool calls in the same assistant turn. Pi runs tool calls in parallel, and this extension also supports concurrent child processes.

`config.json` controls the per-process cap:

```json
{
  "maxConcurrency": 4
}
```

The semaphore is process-local. A nested implementer process has its own cap, so `maxConcurrency` limits direct children of that process, not the whole tree.

## Live UI progress

The parent consumes child JSON events and renders live progress in the `subagent` tool result:

- status icon: running, completed, failed, or cancelled
- model, tool count, duration, token/cost summary when available
- recent tool calls with argument previews
- latest assistant prose message
- nested subagent progress under a running child `subagent` tool call

Collapsed UI summarizes completed tool calls and shows currently running ones. Expanded UI shows the full task prompt, full chronological tool log, and final output for the top-level child.

## Cancellation behavior and limitations

The `subagent` tool receives Pi's abort signal. On cancellation, the extension:

1. marks the in-memory progress as cancelled,
2. sends `SIGTERM` to the child process,
3. sends `SIGKILL` after 3 seconds if the child is still alive,
4. returns a cancellation result with recent tool activity and the last completed assistant text when available.

Important limitation: cancellation state and progress are in memory only. There is no durable checkpoint, transcript file, resumable job, or guaranteed handoff if the process dies abruptly. Temporary prompt/task files are cleaned up, and partial work is only whatever the child already committed through real tool side effects plus the parent UI's last observed JSON events.

If a child is cancelled during a file edit or command, normal tool/process semantics apply; this extension does not roll back filesystem changes.

## Permissions and headless behavior

This dotfiles version does not ship upstream `safe_bash`. Instead, when an agent is granted any of `bash`, `read`, `write`, or `edit`, the child process loads:

```txt
~/.pi/agent/extensions/permissions/index.ts
```

Subagents run headless in JSON/print mode, so permission decisions fail closed:

- `safe` rules allow the call
- `block` rules block the call
- `prompt` rules are blocked because there is no approval UI in the child process

This keeps the interactive main session able to prompt normally while preventing child agents from bypassing the dotfiles permissions policy.

## Configuration and source files

- `pi/extensions/subagents/index.ts` — extension implementation, tool registration, prompt guidelines, process spawning, progress rendering, cancellation, concurrency, child allowlists.
- `pi/extensions/subagents/config.json` — `maxConcurrency` for direct child processes.
- `pi/extensions/subagents/agents/scout.md` — scout frontmatter and system prompt.
- `pi/extensions/subagents/agents/researcher.md` — researcher frontmatter and system prompt.
- `pi/extensions/subagents/agents/implementer.md` — implementer frontmatter/system prompt plus nested delegation guidance.

Agent frontmatter fields used by `index.ts`:

- `name` — tool argument name.
- `description` — parsed agent metadata for maintainers/future UI; the current tool prompt uses the hard-coded `promptGuidelines` in `index.ts`.
- `tools` — comma-separated allowlist. Built-ins are `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`; custom tools map to extensions in `CUSTOM_TOOL_EXTENSIONS`.
- `model` — passed to child `pi` via `--models`.
- `thinking` — passed via `--thinking`.
- `subagent_agents` — optional comma-separated allowlist exposed to that child when it has the `subagent` tool.

## Reload requirements

Agent definitions and `config.json` are read when the extension module loads. After editing `index.ts`, `config.json`, or any `agents/*.md` file, restart/reload the Pi session for the main process to pick up changes.

A running child process has already received its prompt, tool allowlist, model, and environment; changes on disk do not affect it. Children spawned after a reload use the new configuration.
