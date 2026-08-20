# agent-runner

Runs a Claude Code agent in an isolated Docker container to explore a GitHub issue, implement an approved issue, or validate and review a trusted GitHub pull request.

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

## Why `--dangerously-skip-permissions` is acceptable for implement mode

Implement-mode Claude runs with all permission checks disabled, which is normally risky. It's acceptable in this setup
specifically because of layered mitigations, not because the flag itself is safe:

- **Scoped host state mount** — Claude has no access to the original checkout or host home directory. Its only host mount is its own `~/.local/state/agent-runner/<run-id>/` directory, which contains the persisted checkout and Claude session data.
- **Branch protection on GitHub** (see Setup below) — even a compromised/confused agent can't land changes
  directly on the base branch; everything goes through a PR that a human reviews and merges.
- **Non-root container user** — Claude Code itself refuses to run with skip-permissions as root, so the
  image runs as the built-in `node` user, limiting what a container-level exploit could do even within
  the container.
- **Fine-grained, repo-scoped PAT** — the token can't touch other repos or account-wide settings.

None of these alone would be sufficient; together they're why this is a reasonable tradeoff for a private
repo with a trusted issue author (you).

Each initial run clones the target repo into a per-run host state directory, mounted as `/work` in the container. This retains the checkout, including `.git`, its branch, staged/uncommitted/untracked files, Claude session/config state, raw stream output, and metadata after the container exits. The mode then determines the workflow:

- `--investigate` runs Claude with its read-only `--permission-mode plan`: it does not create a branch, install dependencies, run builds/tests, edit code, commit, push, or open a PR. Its 800–1,200-word report is a concise decision memo, not an implementation plan or exhaustive code map. The entrypoint captures the final report, posts it as an issue comment, verifies it, then adds the `exploration-added` label.
- `--implement` checks that the issue has `ready-for-impl`, checks out `agent/issue-<N>` (never touches the base branch locally — a deterrent, not a security boundary), prepares dependencies, and asks Claude to implement the approved plan and open a PR.
- `--review` pins and checks out the current head of an open, trusted PR. It installs dependencies, runs every available `lint`, `typecheck`, `build`, and `test` npm script, then uses the Docker-only `agent-runner-github-code-review` skill and packaged canonical `code-review` skill to produce a static review. The runner posts that report as one GitHub **comment review**; it never approves or requests changes. It then asks whether to start an `--apply-review` run.
- `--apply-review` retrieves the latest marked agent-runner review by the authenticated user and refuses to proceed if the PR head changed since that review. It independently verifies and applies actionable findings, then pushes commits to the existing PR source branch. It never opens a second PR.
- `--test` installs dependencies and runs the repository's `npm test` script when present, without Claude or issue access.

For runs that install dependencies, `PUPPETEER_SKIP_DOWNLOAD=true npm install --dangerously-allow-all-scripts` runs if `package.json` exists. `PUPPETEER_SKIP_DOWNLOAD` stops Puppeteer's own postinstall from attempting a Chrome download during this step — if `puppeteer` or `puppeteer-core` ends up in `node_modules` (directly or transitively — e.g. via `@web/test-runner-puppeteer`), Chrome is installed explicitly afterward with `./node_modules/.bin/puppeteer browsers install chrome` (falling back to `npx puppeteer` only if no local binary exists, e.g. `puppeteer-core`-only setups). Letting both the postinstall *and* the explicit step try to download into the same cache folder caused a race that left a corrupted, partially-extracted install ("folder exists but executable is missing") — skipping the postinstall's attempt makes the explicit step the single, reliable place Chrome actually gets installed. Using the local binary rather than bare `npx puppeteer` also avoids a version mismatch: since Puppeteer is often only a transitive dependency, npx's local-bin resolution isn't guaranteed to find it and can silently fetch a different, unpinned puppeteer version from the registry, targeting a Chrome build the pinned version in `package-lock.json` doesn't actually expect at test time. Separately, Puppeteer's own bundled zip extraction has been observed leaving an incomplete install (small files present, large ones like the `chrome` binary itself missing) even when the downloaded zip is complete and valid — confirmed by manually re-extracting the same zip with system `unzip`, which produced a full, correct install. If the `chrome` binary is missing after Puppeteer's own install step, the entrypoint re-extracts the already-downloaded zip with `unzip` as a repair step rather than re-downloading. The verbose browser-install output is saved at `/work/puppeteer-install.log` (and therefore in the run's persisted state) and is printed only when installation or repair fails.
Claude receives a mode-specific prompt built from the issue title, body, comments, and caller-provided additional instructions. Implement mode uses `--dangerously-skip-permissions` and is told to check `package.json` for lint/build/test scripts. Investigate uses Claude Code's read-only `--permission-mode plan`; it cannot write the report file or post the issue comment itself. Both modes use a compact, colour-coded stream formatter. Implement mode shows readable assistant text and high-level activity; investigate shows high-level activity plus an unconditional 10-second ticker with elapsed time and the age of Claude's last event, then prints the complete final report only after investigation has finished. Tool calls, command text, and command output are hidden.

In implement mode, Claude is told to commit, push, and open the PR itself (`gh pr create` with a descriptive title/body it writes, referencing `Closes #N`) rather than the entrypoint generating a generic "Fix #N" PR. The entrypoint checks afterward whether a PR now exists for the branch; if Claude made changes but didn't finish the git workflow, the entrypoint commits/pushes/opens a generic fallback PR so the work is never silently lost.

The image packages `claude/skills/code-review` as the shared review standard. Its PR-context skill lives at `agent-runner/skills/agent-runner-github-code-review/` and is copied only into the image, so the host `github-code-review` skill remains focused on safely reviewing from an active local checkout.

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
agent-run --investigate 55
agent-run --investigate 55 --base develop -i 'Investigate compatibility with v2.'

# Replace prior marked exploration reports only after a new report is posted and verified.
agent-run --investigate 55 --replace

# Only for an issue whose formal human-approved plan has ready-for-impl.
agent-run --implement 55
agent-run --implement 55 --instruction 'Prefer a small, backward-compatible change.'
agent-run --implement 55 -i 'Update the documentation too.' -i 'Keep the public API unchanged.'

# Validate and thoroughly review a trusted PR. This posts a comment review, then
# asks whether to start a fresh apply-review run against the unchanged PR head.
agent-run --review 42

# Start that apply-review run later. It refuses stale reviews and pushes only to the
# existing PR source branch; it does not open a follow-up PR.
agent-run --apply-review 42

# Clone + npm install + npm test only — no Claude, issue, or PR.
agent-run --test
agent-run --test --base develop

# Inspect a stopped or running run, then explicitly continue an interrupted one.
agent-run status <run-id>
agent-run resume <run-id>
```

`--implement`, `--investigate`, `--review`, `--apply-review`, and `--test` are mutually exclusive; one is required. `--base <branch>` defaults to `main`; for PR modes it must match the PR's base branch. Before a Claude run starts Docker, the CLI fetches and displays the selected issue or PR title and requires a `y`/`yes` confirmation. `--instruction` (or `-i`) appends text to Claude's mode-specific prompt; repeat it to add multiple instructions. Quote each instruction so the shell passes it as one value. It is unavailable with `--test`, which does not run Claude. `status` and `resume` take a run ID printed when a run starts; `resume` starts a fresh container with the persisted worktree and runs `claude --resume` using its saved session ID. Completed runs cannot be resumed.

Exploration is deliberately not implementation-ready planning. Its report is a snapshot for a human to discuss and turn into a formal, approved plan with `/write-plan`; that skill applies `ready-for-impl`. The runner refuses `--implement` unless this label is present. It creates `exploration-added` on demand, after it has captured, posted, and verified the report comment.

`--replace` is available only with `--investigate`. It treats prior marked reports by the authenticated GitHub user as raw research context, posts and verifies the replacement first, then deletes those prior marked comments. A failed or unverified replacement leaves prior comments untouched.

`--test` is for debugging the container/install environment itself (e.g. whether Puppeteer's Chrome download works) without paying for a full Claude run each time. No issue number needed, and it doesn't fetch an issue or touch GitHub beyond cloning.

Run multiple in parallel by invoking `agent-run` multiple times concurrently from different repo directories (separate terminals, or `(cd repo-a && agent-run --investigate 55) & (cd repo-b && agent-run --implement 12) &`); each run builds/uses its own container instance.

## Duplicate-run protection

Before building/running anything, `agent-run` refuses a new investigate, implement, or review run when a container is already running for the same repo and target (`docker ps --filter name=...`). This prevents related runs from racing each other.

In addition, `--implement` refuses to start when an open PR already exists for `agent/issue-<N>` (`gh pr list --head`), avoiding a second implementation for work that is awaiting review or merge. `--apply-review` requires a marked review of the exact current head SHA, so it cannot apply stale findings. These checks are best-effort (there is a small window before the container starts), but catch the common cases.

## Testing

```bash
./agent-runner/test.sh
```

This runs CLI and fake-Docker regression checks for persisted first runs, status, resumption, completed-run refusal, dirty/untracked worktree preservation, and interruption handling. A full Docker build also verifies that the canonical and Docker-only review skills are packaged into the image.

## Inspecting, resuming, and cleaning up runs

Every run prints a run ID and state directory. Its state is stored under
`~/.local/state/agent-runner/<run-id>/` (or `$XDG_STATE_HOME/agent-runner/<run-id>/`) with mode `0700`:

- `work/` is mounted at `/work` and contains the clone, branch, and all Git changes;
- `home/` is mounted at `/home/node` and preserves Claude Code's session/config state. Mounting the directory, rather than `claude.json` as an individual file, lets Claude Code atomically replace its configuration file;
- `metadata.json` records the target, current container, session ID, timestamps, and lifecycle status;
- `work/claude-stream.jsonl` holds raw Claude stream output.

Use the run ID to inspect either a running or stopped run:

```
agent-run status jackfranklin-routemaster-55-20260718-221533-a1b2c3d4
```

If Docker was stopped or the run was interrupted, continue it explicitly. This creates a replacement container, mounts the same state, and resumes the saved Claude session without cloning again:

```
agent-run resume jackfranklin-routemaster-55-20260718-221533-a1b2c3d4
```

An interrupted run does not invoke implement mode's fallback commit/PR workflow. A normal zero-exit run is marked `completed`, and `resume` refuses it to prevent an accidental second pass. Containers are still retained for Docker-level inspection, but deleting one cannot destroy the persisted work.

After the run is no longer needed, remove its stopped container(s) and then its state directory:

```
docker ps -a --filter name=agent-runner
docker rm <container-name>
rm -rf ~/.local/state/agent-runner/<run-id>
```
