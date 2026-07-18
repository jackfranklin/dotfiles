# agent-runner

Runs a Claude Code agent in an isolated Docker container to implement a GitHub issue and open a PR.

Each run:
1. Clones the target repo fresh into the container.
2. Immediately checks out `agent/issue-<N>` (never touches the base branch locally — a deterrent, not a security boundary).
3. Runs `npm install --dangerously-allow-all-scripts` if `package.json` exists, so dependencies (including
   things like Puppeteer's Chrome download via postinstall) are ready before Claude starts.
4. Runs `claude -p "..." --dangerously-skip-permissions` with a prompt built from the issue title/body. Claude
   is told to check `package.json` itself for lint/build/test scripts and run whichever are relevant before
   finishing — there's no separate hardcoded lint/build/test step in the entrypoint. Output is streamed as
   `stream-json` and piped through [`format-claude-stream`](https://github.com/Khan/format-claude-stream) for
   readable live progress instead of just the final response.
5. Claude is told to commit, push, and open the PR itself (`gh pr create` with a descriptive title/body it
   writes, referencing `Closes #N`) rather than the entrypoint generating a generic "Fix #N" PR. The entrypoint
   checks afterward whether a PR now exists for the branch; if Claude made changes but didn't finish the git
   workflow, the entrypoint commits/pushes/opens a generic fallback PR so the work is never silently lost.

## Installing Docker

```
make ubuntu-docker-deps
```

This runs, in order:

1. Removes any old/conflicting Docker packages (`docker`, `docker-engine`, `docker.io`, `containerd`, `runc`).
2. Adds Docker's official apt repo (with its signing key), rather than relying on the older `docker.io` package
   in Ubuntu's default repos.
3. Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, and the `buildx`/`compose` plugins.
4. Runs `sudo usermod -aG docker $USER` — adds your user to the `docker` group so you can run `docker` without
   `sudo`.

After it finishes, log out/in (or run `newgrp docker` in your current shell) so the new group membership takes
effect, then verify with `docker run hello-world`.

**TLDR on the `usermod` step:** the Docker daemon runs as root and talks over a Unix socket owned by
`root:docker`. Being in the `docker` group is what lets your normal user hit that socket without `sudo` — but
it's effectively equivalent to passwordless root on the machine (a container can bind-mount `/` from the host
and chroot into it). Fine for a personal single-user dev box; just don't treat it as a sandboxed permission.

## Setup

On GitHub, protect the base branch (e.g. `main`) with a ruleset requiring PRs and blocking force-pushes/deletions,
with a bypass list for yourself/admins. This is what actually stops the agent (or a bug in this script) from
landing changes directly on the base branch — the branch-checkout step above is only a deterrent, since the
container has full shell access and could work around local-only guardrails.

Create a fine-grained GitHub PAT scoped to just the repo(s) you'll run this against, with:
- Contents: read/write
- Pull requests: read/write
- Issues: read

Generate a Claude Code OAuth token (requires a Pro/Max/Team/Enterprise subscription) by running
`claude setup-token` on your host machine. It walks you through browser OAuth and prints a token
(`sk-ant-oat01-...`) once — it isn't saved anywhere, so copy it immediately.

## Install

```
make agent-runner
```

Symlinks `agent-runner/bin/agent-run` to `~/.local/bin/agent-run`.

## Usage

```fish
set -x AGENT_RUNNER_GH_TOKEN <fine-grained PAT scoped to the repo>
set -x AGENT_RUNNER_CLAUDE_OAUTH_TOKEN <token from `claude setup-token`>

cd ~/code/routemaster   # repo owner defaults to jackfranklin, repo name comes from cwd
agent-run 55
agent-run 55 develop   # optional base branch, defaults to main
```

Run multiple in parallel by invoking `agent-run` multiple times concurrently from different repo
directories (separate terminals, or `(cd repo-a && agent-run 55) & (cd repo-b && agent-run 12) &`);
each run builds/uses its own container instance.

## Duplicate-run protection

Before building/running anything, `agent-run` checks two things and refuses to start if either is true:

1. **An open PR already exists** for `agent/issue-<N>` (`gh pr list --head`) — avoids re-running an issue
   that's already been implemented and is just waiting on review/merge.
2. **A container is already running** for this exact repo+issue (`docker ps --filter name=...`) — avoids
   two containers racing to implement the same issue concurrently.

Both checks are best-effort (there's a small window between the check and the container actually starting),
but they catch the common case: running `agent-run 55` twice by mistake, or re-running an issue you forgot
already got a PR.

## Inspecting and cleaning up containers

Containers are **not** removed automatically after a run (no `--rm`), so a bug or crash doesn't
silently destroy the agent's work — it stays inspectable until you clean it up. Each container is
named `agent-runner-<owner>-<repo>-<issue>-<timestamp>`, e.g.
`agent-runner-jackfranklin-routemaster-55-20260718-221533`.

List all of them:

```
docker ps -a --filter name=agent-runner
```

Pull a file out of a specific container (useful if a run finished but the PR step didn't fire):

```
docker cp agent-runner-jackfranklin-routemaster-55-20260718-221533:/work/repo/docs/terrain-types.md .
```

Once you've confirmed a run's PR looks right (or salvaged what you needed), remove it:

```
docker rm agent-runner-jackfranklin-routemaster-55-20260718-221533
```

or clean up everything at once:

```
docker rm $(docker ps -a --filter name=agent-runner -q)
```
