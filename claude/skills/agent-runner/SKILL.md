---
name: agent-runner
description: Run, inspect, or clean up agent-runner Docker containers — the tool that runs Claude against a GitHub issue in an isolated container and opens a PR. Use when the user wants to run agent-run, asks which container belongs to which issue, a run finished without a PR, or wants to tidy up old containers.
---

`agent-runner` (in `~/dotfiles/agent-runner/`) runs a Claude Code agent inside a Docker container to implement a GitHub issue and open a PR. Full design/rationale lives in `~/dotfiles/agent-runner/README.md` — read it if something here doesn't cover the situation.

## Running it

Before starting a real run (not needed for `--test-only`), check the issue has a fully formed implementation plan by confirming it carries the `ready-for-impl` label (added by the `write-plan` skill once it posts a complete plan):

```
gh issue view <issue-number> --json labels --jq '.labels[].name'
```

If `ready-for-impl` is missing, don't proceed silently — tell the user the issue doesn't appear to have a finished plan yet and confirm they still want to run it (e.g. the plan may exist but the label wasn't applied, or the issue may genuinely need more investigation first via `write-plan`).

From inside the target repo's working directory on the host (not inside a container):

```
agent-run <issue-number> [base-branch]
agent-run --test-only [base-branch]
```

The GitHub owner is hardcoded to `jackfranklin`; the repo name comes from the current directory's basename. `base-branch` defaults to `main`.

`--test-only` clones, `npm install`s, and runs `npm test` — no Claude, no PR, no duplicate-run checks. Use it to debug the container/install environment itself (e.g. a Puppeteer/Chrome problem) without paying for a full Claude run each time.

Required env vars (fish): `AGENT_RUNNER_GH_TOKEN`, `AGENT_RUNNER_CLAUDE_OAUTH_TOKEN`. If either is unset the script fails fast with a clear message — don't troubleshoot further than checking they're exported.

Before doing anything else, the script refuses to start if either an open PR already exists for `agent/issue-<N>`, or a container is already running for that exact repo+issue — this guards against duplicate runs. If you hit one of these refusals, don't work around it by bypassing the check; investigate the existing PR/container instead (see below).

## Containers are never auto-removed

`docker run` is invoked **without** `--rm` deliberately: if a run bug (like a wrong "no changes made" check) causes the script to skip the commit/push/PR step, the container's filesystem is the only remaining copy of whatever Claude built. Auto-removal would silently destroy that work. This means containers accumulate and must be cleaned up manually — see below.

## Naming: how a container maps to an issue

Every container is named:

```
agent-runner-<owner>-<repo>-<issue>-<YYYYMMDD-HHMMSS>
```

e.g. `agent-runner-jackfranklin-routemaster-55-20260718-221533`. The timestamp exists so re-running the same issue doesn't collide with a still-present earlier attempt.

List all agent-runner containers, most useful first:

```
docker ps -a --filter name=agent-runner --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
```

Match on the `<repo>-<issue>` segment to find the container(s) for a specific issue — there may be more than one if it was run multiple times.

## A run finished but no PR appeared

Check the container's final log output first:

```
docker logs <container-name>
```

If it created files but the script bailed out before pushing, pull them out directly rather than re-running (re-running burns another Claude session for work that already happened):

```
docker cp <container-name>:/work/repo/<path> .
```

The repo lives at `/work/repo` inside the container. For deeper inspection (e.g. to check `git status` or `git log` inside the container's clone), start an interactive shell in the stopped container:

```
docker start -ai <container-name>
```

(This restarts the entrypoint by default — if you only want a shell without re-running it, use `docker commit <container-name> tmp-image && docker run --rm -it --entrypoint bash tmp-image`.)

## Cleaning up

Once a run's PR is confirmed good (or its work has been salvaged), remove the container:

```
docker rm <container-name>
```

Remove all agent-runner containers at once:

```
docker rm $(docker ps -a --filter name=agent-runner -q)
```

Don't reach for `docker system prune` or similar broad cleanup commands here — they affect containers/images unrelated to agent-runner and are out of scope for this skill.
