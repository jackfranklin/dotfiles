# agent-runner

Runs a Claude Code agent in an isolated Docker container to either explore a GitHub issue and post a scope report, or implement an approved issue and open a PR.

**Assumes a Node/npm repo.** The entrypoint only knows how to `npm install` and defers to Claude to run
whatever `package.json` scripts are relevant. A non-Node repo isn't actively unsupported, but nothing in
the entrypoint helps it — Claude would have to figure out its own build/test setup from scratch.

**Network access is not restricted.** The container has full outbound network access — there's no
allowlisting to GitHub/npm/Anthropic only. Container filesystem isolation and non-root execution are the
actual boundaries here, not network sandboxing. Worth revisiting if this ever runs against untrusted issue
content (e.g. a public repo where issue text is attacker-controlled).

**Chrome/Puppeteer OS dependencies are installed at image-build time.** Headless Chrome needs a pile of OS
shared libraries to actually launch (separate from whether it downloads/extracts correctly). The Dockerfile
runs `npx @puppeteer/browsers install chrome --install-deps` as root during build (a throwaway install purely
to trigger `apt` installing the right libraries — Puppeteer's own tooling knows the OS-specific list, so we
don't hand-maintain one) since `--install-deps` requires root and the container runs as non-root `node` at
runtime. This can't be done per-repo at runtime since the actual pinned Chrome version isn't known until
`agent-run` clones a specific repo — but the OS-level libraries a given Chrome major version needs have been
stable enough in practice that installing them generically at build time works for whatever gets pinned later.

**Containers run with `--cap-add=SYS_ADMIN`.** Chrome's sandbox needs either a SUID-root sandbox binary
(can't set that up — the container runs as non-root `node` throughout, deliberately, so Claude Code's own
root-guard doesn't block `--dangerously-skip-permissions`) or the `SYS_ADMIN` capability so its own
unprivileged-namespace sandbox can work. This is Puppeteer's own documented recommendation for Docker rather
than the more common workaround of passing `--no-sandbox` to Chrome — `--no-sandbox` isn't something
`agent-runner` can inject generically anyway, since browser launch args live inside each repo's own test
config, not in this tool. `SYS_ADMIN` is a meaningfully broad capability (grants things like mount/umount,
beyond just sandboxing); acceptable here because it's scoped to an already-isolated, ephemeral, per-run
container, not the host.

## Why `--dangerously-skip-permissions` is acceptable for fix mode

Fix-mode Claude runs with all permission checks disabled, which is normally risky. It's acceptable in this setup
specifically because of layered mitigations, not because the flag itself is safe:

- **Container isolation** — Claude only has access to the container's filesystem, not the host.
- **Branch protection on GitHub** (see Setup below) — even a compromised/confused agent can't land changes
  directly on the base branch; everything goes through a PR that a human reviews and merges.
- **Non-root container user** — Claude Code itself refuses to run with skip-permissions as root, so the
  image runs as the built-in `node` user, limiting what a container-level exploit could do even within
  the container.
- **Fine-grained, repo-scoped PAT** — the token can't touch other repos or account-wide settings.

None of these alone would be sufficient; together they're why this is a reasonable tradeoff for a private
repo with a trusted issue author (you).

Each run clones the target repo fresh into the container at the selected base branch. The mode then determines the workflow:

- `--explore-plan` runs Claude with its read-only `--permission-mode plan`: it does not create a branch, install dependencies, run builds/tests, edit code, commit, push, or open a PR. The entrypoint captures Claude's final report, posts it as an issue comment, verifies it, then adds the `exploration-added` label.
- `--fix` checks that the issue has `ready-for-impl`, checks out `agent/issue-<N>` (never touches the base branch locally — a deterrent, not a security boundary), prepares dependencies, and asks Claude to implement the approved plan and open a PR.
- `--test-only` installs dependencies and runs the repository's `npm test` script when present, without Claude or issue access.

For runs that install dependencies, `PUPPETEER_SKIP_DOWNLOAD=true npm install --dangerously-allow-all-scripts` runs if `package.json` exists. `PUPPETEER_SKIP_DOWNLOAD` stops Puppeteer's own postinstall from attempting a Chrome download during this step — if `puppeteer` or `puppeteer-core` ends up in `node_modules` (directly or transitively — e.g. via `@web/test-runner-puppeteer`), Chrome is installed explicitly afterward with `./node_modules/.bin/puppeteer browsers install chrome` (falling back to `npx puppeteer` only if no local binary exists, e.g. `puppeteer-core`-only setups). Letting both the postinstall *and* the explicit step try to download into the same cache folder caused a race that left a corrupted, partially-extracted install ("folder exists but executable is missing") — skipping the postinstall's attempt makes the explicit step the single, reliable place Chrome actually gets installed. Using the local binary rather than bare `npx puppeteer` also avoids a version mismatch: since Puppeteer is often only a transitive dependency, npx's local-bin resolution isn't guaranteed to find it and can silently fetch a different, unpinned puppeteer version from the registry, targeting a Chrome build the pinned version in `package-lock.json` doesn't actually expect at test time. Separately, Puppeteer's own bundled zip extraction has been observed leaving an incomplete install (small files present, large ones like the `chrome` binary itself missing) even when the downloaded zip is complete and valid — confirmed by manually re-extracting the same zip with system `unzip`, which produced a full, correct install. If the `chrome` binary is missing after Puppeteer's own install step, the entrypoint re-extracts the already-downloaded zip with `unzip` as a repair step rather than re-downloading.
Claude receives a mode-specific prompt built from the issue title, body, comments, and caller-provided additional instructions. Fix mode uses `--dangerously-skip-permissions` and is told to check `package.json` for lint/build/test scripts. Exploration uses Claude Code's read-only `--permission-mode plan`; it cannot write the report file or post the issue comment itself. Both modes use a compact, colour-coded stream formatter. Fix mode shows readable assistant text and high-level activity; exploration shows high-level activity plus an unconditional 10-second ticker with elapsed time and the age of Claude's last event, then prints the complete final report only after exploration has finished. Tool calls, command text, and command output are hidden.

In fix mode, Claude is told to commit, push, and open the PR itself (`gh pr create` with a descriptive title/body it writes, referencing `Closes #N`) rather than the entrypoint generating a generic "Fix #N" PR. The entrypoint checks afterward whether a PR now exists for the branch; if Claude made changes but didn't finish the git workflow, the entrypoint commits/pushes/opens a generic fallback PR so the work is never silently lost.

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

Requires the `gh` CLI installed on the **host**, not just inside the container — `agent-run`'s duplicate-run
check (see below) shells out to it before ever touching Docker.

On GitHub, protect the base branch (e.g. `main`) with a ruleset requiring PRs and blocking force-pushes/deletions,
with a bypass list for yourself/admins. This is what actually stops the agent (or a bug in this script) from
landing changes directly on the base branch — the branch-checkout step above is only a deterrent, since the
container has full shell access and could work around local-only guardrails.

Create a fine-grained GitHub PAT scoped to just the repo(s) you'll run this against, with:
- Contents: read/write
- Pull requests: read/write
- Issues: read/write

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

# Initial static investigation of a rough issue. Posts a report comment and adds exploration-added.
agent-run --explore-plan 55
agent-run --explore-plan 55 --base develop -i 'Investigate compatibility with v2.'

# Only for an issue whose formal human-approved plan has ready-for-impl.
agent-run --fix 55
agent-run --fix 55 --instruction 'Prefer a small, backward-compatible change.'
agent-run --fix 55 -i 'Update the documentation too.' -i 'Keep the public API unchanged.'

# Clone + npm install + npm test only — no Claude, issue, or PR.
agent-run --test-only
agent-run --test-only --base develop
```

`--fix`, `--explore-plan`, and `--test-only` are mutually exclusive; one is required. `--base <branch>` defaults to `main`. Before a fix or exploration run starts Docker, the CLI fetches and displays the selected issue's title and requires a `y`/`yes` confirmation. `--instruction` (or `-i`) appends text to Claude's mode-specific prompt; repeat it to add multiple instructions. Quote each instruction so the shell passes it as one value. It is unavailable with `--test-only`, which does not run Claude.

Exploration is deliberately not implementation-ready planning. Its report is a snapshot for a human to discuss and turn into a formal, approved plan with `/write-plan`; that skill applies `ready-for-impl`. The runner refuses `--fix` unless this label is present. It creates `exploration-added` on demand, after it has captured, posted, and verified the report comment.

`--test-only` is for debugging the container/install environment itself (e.g. whether Puppeteer's Chrome download works) without paying for a full Claude run each time. No issue number needed, and it doesn't fetch an issue or touch GitHub beyond cloning.

Run multiple in parallel by invoking `agent-run` multiple times concurrently from different repo directories (separate terminals, or `(cd repo-a && agent-run --explore-plan 55) & (cd repo-b && agent-run --fix 12) &`); each run builds/uses its own container instance.

## Duplicate-run protection

Before building/running anything, `agent-run` refuses a new exploration or fix run when a container is already running for the same repo and issue (`docker ps --filter name=...`). This prevents exploration and implementation from racing each other.

In addition, `--fix` refuses to start when an open PR already exists for `agent/issue-<N>` (`gh pr list --head`), avoiding a second implementation for work that is awaiting review or merge. These checks are best-effort (there is a small window before the container starts), but catch the common cases.

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

If an exploration run exits without its report comment, it prints an exact recovery command. The report is normally saved at `/work/exploration-report.md`, for example:

```
docker cp agent-runner-jackfranklin-routemaster-55-20260718-221533:/work/exploration-report.md ./exploration-report-55.md
```

Once you've confirmed a run's PR looks right (or salvaged what you needed), remove it:

```
docker rm agent-runner-jackfranklin-routemaster-55-20260718-221533
```

or clean up everything at once:

```
docker rm $(docker ps -a --filter name=agent-runner -q)
```
