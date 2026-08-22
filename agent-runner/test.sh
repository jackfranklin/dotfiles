#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${SCRIPT_DIR}/bin/agent-run"
ENTRYPOINT="${SCRIPT_DIR}/entrypoint.sh"

expect_success() {
  local description="$1"
  local expected="$2"
  shift 2
  local output
  if ! output="$("${RUNNER}" "$@" 2>&1)"; then
    echo "FAIL: ${description}: command failed unexpectedly" >&2
    echo "${output}" >&2
    exit 1
  fi
  if [[ "${output}" != *"${expected}"* ]]; then
    echo "FAIL: ${description}: expected output to contain ${expected@Q}" >&2
    echo "${output}" >&2
    exit 1
  fi
}

expect_failure() {
  local description="$1"
  local expected="$2"
  shift 2
  local output
  if output="$("${RUNNER}" "$@" 2>&1)"; then
    echo "FAIL: ${description}: command unexpectedly succeeded" >&2
    exit 1
  fi
  if [[ "${output}" != *"${expected}"* ]]; then
    echo "FAIL: ${description}: expected output to contain ${expected@Q}" >&2
    echo "${output}" >&2
    exit 1
  fi
}

expect_output() {
  local description="$1"
  local expected="$2"
  shift 2
  local output
  if ! output="$("$@" 2>&1)"; then
    echo "FAIL: ${description}: command failed unexpectedly" >&2
    echo "${output}" >&2
    exit 1
  fi
  if [[ "${output}" != *"${expected}"* ]]; then
    echo "FAIL: ${description}: expected output to contain ${expected@Q}" >&2
    echo "${output}" >&2
    exit 1
  fi
}

test -f "${SCRIPT_DIR}/skills/agent-runner-github-code-review/SKILL.md"

expect_success 'help documents implementation' '--implement <issue-number>' --help
expect_success 'help documents investigation' '--investigate <issue-number>' --help
expect_success 'help documents PR review' '--review <pr-number>' --help
expect_success 'help documents applying a review' '--apply-review <pr-number>' --help
expect_success 'help documents test mode' '--test [--base <branch>]' --help
expect_success 'help explains test mode purpose' "Verify the runner's dependency and test environment without Claude:" --help
expect_success 'help documents status' 'agent-run status <run-id>' --help
expect_success 'help documents resume' 'agent-run resume <run-id>' --help
expect_success 'help explains live output' 'Normal runs still stream Claude output live.' --help
expect_success 'help explains recovery commands' 'only after a run has stopped or been interrupted' --help
expect_failure 'review requires a positive PR number' '--review requires one positive pull request number' --review 0
expect_failure 'review fixes require a positive PR number' '--apply-review requires one positive pull request number' --apply-review nope
expect_failure 'replacement is exploration-only' '--replace is only available with --investigate' --review 42 --replace
expect_failure 'test rejects instructions' '--instruction cannot be used with --test' --test --instruction nope
expect_failure 'old fix mode is unavailable' 'Unknown option: --fix' --fix 60

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT
FAKE_BIN="${TMPDIR}/bin"
FAKE_DOCKER_LOG="${TMPDIR}/docker.log"
FAKE_GH_LOG="${TMPDIR}/gh.log"
mkdir -p "${FAKE_BIN}" "${TMPDIR}/docker-state" "${TMPDIR}/repo"

cat > "${FAKE_BIN}/docker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%q ' "$@" >> "${FAKE_DOCKER_LOG}"
printf '\n' >> "${FAKE_DOCKER_LOG}"
case "$1" in
  build) exit 0 ;;
  inspect)
    name="${!#}"
    if [ ! -f "${FAKE_DOCKER_STATE}/${name}" ]; then
      exit 1
    fi
    state="$(cat "${FAKE_DOCKER_STATE}/${name}")"
    if [[ "$*" == *'.State.Running'* ]]; then
      [ "${state}" = running ] && printf 'true\n' || printf 'false\n'
    else
      printf '%s\n' "${state}"
    fi
    ;;
  run)
    name=""
    while [ "$#" -gt 0 ]; do
      if [ "$1" = --name ]; then
        name="$2"
        break
      fi
      shift
    done
    printf 'exited\n' > "${FAKE_DOCKER_STATE}/${name}"
    ;;
  ps) ;;
  *) echo "unexpected fake docker command: $1" >&2; exit 1 ;;
esac
EOF

cat > "${FAKE_BIN}/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%q ' "$@" >> "${FAKE_GH_LOG}"
printf '\n' >> "${FAKE_GH_LOG}"
if [ "$1" = repo ] && [ "$2" = clone ]; then
  target="$4"
  mkdir -p "${target}"
  git init -q "${target}"
  git -C "${target}" config user.name test
  git -C "${target}" config user.email test@example.com
  git -C "${target}" commit --allow-empty -qm initial
  printf '{}\n' > "${target}/package.json"
  exit 0
fi
if [ "$1" = issue ] && [ "$2" = view ]; then
  if [[ "$*" == *'title,body,comments'* ]]; then
    printf '%s\n' '{"title":"Test issue","body":"","comments":[]}'
  else
    printf '%s\n' 'Test issue'
  fi
fi
EOF

cat > "${FAKE_BIN}/npm" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  install)
    if [ -n "${PUPPETEER_SKIP_DOWNLOAD:-}" ]; then
      echo 'PUPPETEER_SKIP_DOWNLOAD must not be set' >&2
      exit 1
    fi
    exit 0
    ;;
  run) exit 0 ;;
  *) echo "unexpected fake npm command: $1" >&2; exit 1 ;;
esac
EOF

cat > "${FAKE_BIN}/claude" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "$$" > "${FAKE_CLAUDE_PID}"
trap 'exit 143' TERM
while true; do sleep 1; done
EOF

cat > "${FAKE_BIN}/format-claude-progress.mjs" <<'EOF'
#!/usr/bin/env bash
cat
EOF
chmod +x "${FAKE_BIN}/docker" "${FAKE_BIN}/gh" "${FAKE_BIN}/npm" "${FAKE_BIN}/claude" "${FAKE_BIN}/format-claude-progress.mjs"

runner_env=(
  "PATH=${FAKE_BIN}:${PATH}"
  "XDG_STATE_HOME=${TMPDIR}/state"
  "AGENT_RUNNER_RUN_ID=first-run"
  'AGENT_RUNNER_GH_TOKEN=token'
  'AGENT_RUNNER_CLAUDE_OAUTH_TOKEN=oauth'
  "FAKE_DOCKER_LOG=${FAKE_DOCKER_LOG}"
  "FAKE_DOCKER_STATE=${TMPDIR}/docker-state"
  "FAKE_GH_LOG=${FAKE_GH_LOG}"
)

# A fake Docker run leaves the state for the host CLI to inspect. This verifies
# first-run metadata and every bind mount without needing a real image.
expect_output 'empty confirmation starts the run' 'Run ID: first-run' \
  env "${runner_env[@]}" bash -c "cd '${TMPDIR}/repo' && printf '\\n' | '${RUNNER}' --investigate 60"
STATE_DIR="${TMPDIR}/state/agent-runner/first-run"
test -d "${STATE_DIR}/work"
test -d "${STATE_DIR}/home"
test -f "${STATE_DIR}/metadata.json"
jq -e '.status == "starting" and .session_id != ""' "${STATE_DIR}/metadata.json" >/dev/null
grep -Fq "source=${STATE_DIR}/work" "${FAKE_DOCKER_LOG}"
grep -Fq "source=${STATE_DIR}/home" "${FAKE_DOCKER_LOG}"
grep -Fq 'target=/home/node ' "${FAKE_DOCKER_LOG}"
if grep -Fq 'target=/home/node/.claude.json' "${FAKE_DOCKER_LOG}"; then
  echo 'FAIL: Claude configuration must not be bind-mounted as an individual file' >&2
  exit 1
fi

# Populate the checkout as a completed first container would have done, then
# prove status reads the mounted Git state and persisted raw output.
mkdir -p "${STATE_DIR}/work/repo"
git init -q "${STATE_DIR}/work/repo"
git -C "${STATE_DIR}/work/repo" config user.name test
git -C "${STATE_DIR}/work/repo" config user.email test@example.com
git -C "${STATE_DIR}/work/repo" commit --allow-empty -qm initial
git -C "${STATE_DIR}/work/repo" checkout -qb agent/issue-60
printf 'keep me\n' > "${STATE_DIR}/work/repo/untracked.txt"
printf '{"type":"assistant","text":"persisted output"}\n' > "${STATE_DIR}/work/claude-stream.jsonl"
printf 'exited\n' > "${TMPDIR}/docker-state/agent-runner-first-run"
expect_output 'status reports persisted Git state' 'Working tree: dirty' \
  env "PATH=${FAKE_BIN}:${PATH}" "XDG_STATE_HOME=${TMPDIR}/state" "FAKE_DOCKER_LOG=${FAKE_DOCKER_LOG}" "FAKE_DOCKER_STATE=${TMPDIR}/docker-state" "${RUNNER}" status first-run

# A stopped run gets a fresh container in resume mode; neither the branch nor
# untracked files are replaced because Docker receives the existing work mount.
jq '.status = "interrupted"' "${STATE_DIR}/metadata.json" > "${STATE_DIR}/metadata.json.tmp"
mv "${STATE_DIR}/metadata.json.tmp" "${STATE_DIR}/metadata.json"
# Match state from the pre-home-mount layout and verify resume migrates it.
rmdir "${STATE_DIR}/home"
mkdir "${STATE_DIR}/claude"
printf 'saved session\n' > "${STATE_DIR}/claude/session"
printf '{"projects":{}}\n' > "${STATE_DIR}/claude.json"
expect_output 'resume starts a fresh container' 'Run ID: first-run' \
  env "${runner_env[@]}" bash -c "cd '${TMPDIR}/repo' && '${RUNNER}' resume first-run"
grep -Fq 'RUN_PHASE=resume' "${FAKE_DOCKER_LOG}"
test "$(jq -r '.status' "${STATE_DIR}/metadata.json")" = running
test -f "${STATE_DIR}/work/repo/untracked.txt"
test "$(git -C "${STATE_DIR}/work/repo" branch --show-current)" = agent/issue-60
test "$(< "${STATE_DIR}/home/.claude/session")" = 'saved session'
test -f "${STATE_DIR}/home/.claude.json"
test ! -e "${STATE_DIR}/claude"
test ! -e "${STATE_DIR}/claude.json"

jq '.status = "completed"' "${STATE_DIR}/metadata.json" > "${STATE_DIR}/metadata.json.tmp"
mv "${STATE_DIR}/metadata.json.tmp" "${STATE_DIR}/metadata.json"
expect_output 'completed runs refuse resumption' 'cannot be resumed' \
  bash -c "if env '${runner_env[0]}' '${runner_env[1]}' '${runner_env[3]}' '${runner_env[4]}' '${runner_env[5]}' '${runner_env[6]}' '${RUNNER}' resume first-run; then exit 1; fi"

# Exercise the entrypoint itself with fake gh/Claude. Claude interrupts its
# parent, so the EXIT trap must persist interrupted and must not reach implement mode's
# fallback PR workflow.
INTERRUPT_STATE="${TMPDIR}/interrupted"
mkdir -p "${INTERRUPT_STATE}" "${TMPDIR}/interrupt-work" "${TMPDIR}/interrupt-home"
jq -n --arg session_id '123e4567-e89b-12d3-a456-426614174000' \
  '{run_id:"interrupted", repo:"jackfranklin/demo", target:"issue #60", container_target:"60", base_branch:"main", mode:"implement", issue_number:"60", pr_number:"", container_name:"interrupted-container", session_id:$session_id, status:"running"}' > "${INTERRUPT_STATE}/metadata.json"
FAKE_CLAUDE_PID="${TMPDIR}/claude.pid"
env "PATH=${FAKE_BIN}:${PATH}" "HOME=${TMPDIR}/interrupt-home" "AGENT_RUNNER_STATE_DIR=${INTERRUPT_STATE}" "AGENT_RUNNER_WORK_ROOT=${TMPDIR}/interrupt-work" \
  'REPO=jackfranklin/demo' 'MODE=implement' 'ISSUE_NUMBER=60' 'PR_NUMBER=' 'BASE_BRANCH=main' 'RUN_PHASE=initial' \
  'SESSION_ID=123e4567-e89b-12d3-a456-426614174000' 'CONTAINER_NAME=interrupted-container' 'GH_TOKEN=token' 'CLAUDE_CODE_OAUTH_TOKEN=oauth' \
  'GIT_AUTHOR_NAME=test' 'GIT_AUTHOR_EMAIL=test@example.com' "FAKE_GH_LOG=${FAKE_GH_LOG}" "FAKE_CLAUDE_PID=${FAKE_CLAUDE_PID}" "${ENTRYPOINT}" > "${TMPDIR}/interrupted-output.log" 2>&1 &
ENTRYPOINT_PID=$!
for _ in $(seq 1 20); do
  [ -f "${FAKE_CLAUDE_PID}" ] && break
  sleep 0.1
done
if [ ! -f "${FAKE_CLAUDE_PID}" ]; then
  echo 'FAIL: interrupted entrypoint did not start Claude' >&2
  kill -TERM "${ENTRYPOINT_PID}" 2>/dev/null || true
  exit 1
fi
kill -TERM "${ENTRYPOINT_PID}"
kill -TERM "$(cat "${FAKE_CLAUDE_PID}")" 2>/dev/null || true
set +e
wait "${ENTRYPOINT_PID}"
INTERRUPT_EXIT=$?
set -e
if [ "${INTERRUPT_EXIT}" -eq 0 ]; then
  echo 'FAIL: interrupted entrypoint unexpectedly succeeded' >&2
  exit 1
fi
test "$(jq -r '.status' "${INTERRUPT_STATE}/metadata.json")" = interrupted
if grep -Fq 'pr list' "${FAKE_GH_LOG}"; then
  echo 'FAIL: interrupted implement run reached the fallback PR workflow' >&2
  exit 1
fi

echo 'agent-runner CLI tests passed'
