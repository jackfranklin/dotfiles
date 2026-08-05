#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${SCRIPT_DIR}/bin/agent-run"

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

test -f "${SCRIPT_DIR}/skills/agent-runner-github-code-review/SKILL.md"

expect_success 'help documents PR review' '--review-pr <pr-number>' --help
expect_success 'help documents review fixes' '--fix-review <pr-number>' --help
expect_failure 'review requires a positive PR number' '--review-pr requires one positive pull request number' --review-pr 0
expect_failure 'review fixes require a positive PR number' '--fix-review requires one positive pull request number' --fix-review nope
expect_failure 'replacement is exploration-only' '--replace is only available with --explore-plan' --review-pr 42 --replace
expect_failure 'test-only rejects instructions' '--instruction cannot be used with --test-only' --test-only --instruction nope

echo 'agent-runner CLI tests passed'
