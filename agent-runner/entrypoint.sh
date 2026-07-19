#!/usr/bin/env bash
set -euo pipefail

# Required env vars:
#   REPO                  - owner/repo to work on (e.g. jackfranklin/my-app)
#   ISSUE_NUMBER          - GitHub issue number to implement
#   GH_TOKEN              - fine-grained GitHub PAT scoped to REPO (contents, PRs, issues: read/write)
#   CLAUDE_CODE_OAUTH_TOKEN - long-lived token from `claude setup-token`, tied to your Claude subscription
#   GIT_AUTHOR_NAME        - git user.name to commit as (passed through from the host's git config)
#   GIT_AUTHOR_EMAIL       - git user.email to commit as (passed through from the host's git config)
#
# Optional:
#   BASE_BRANCH    - branch to branch from / PR against (default: main)
#   TEST_ONLY       - if set, clone + npm install + npm test only; skip Claude/PR entirely

: "${REPO:?REPO env var required, e.g. owner/repo}"
: "${ISSUE_NUMBER:?ISSUE_NUMBER env var required}"
: "${GH_TOKEN:?GH_TOKEN env var required}"
: "${CLAUDE_CODE_OAUTH_TOKEN:?CLAUDE_CODE_OAUTH_TOKEN env var required (generate with: claude setup-token)}"
: "${GIT_AUTHOR_NAME:?GIT_AUTHOR_NAME env var required}"
: "${GIT_AUTHOR_EMAIL:?GIT_AUTHOR_EMAIL env var required}"
BASE_BRANCH="${BASE_BRANCH:-main}"

BRANCH="agent/issue-${ISSUE_NUMBER}"
WORKDIR="/work/repo"

TOKEN_LEN="${#CLAUDE_CODE_OAUTH_TOKEN}"
echo "==> CLAUDE_CODE_OAUTH_TOKEN: ${CLAUDE_CODE_OAUTH_TOKEN:0:13}...${CLAUDE_CODE_OAUTH_TOKEN: -4} (length ${TOKEN_LEN})"

echo "==> Cloning ${REPO}"
gh repo clone "${REPO}" "${WORKDIR}" -- --branch "${BASE_BRANCH}"
cd "${WORKDIR}"

if [ -f package.json ]; then
  echo "==> Installing dependencies"
  # Scoped to just this install step (not a Dockerfile-wide ENV) so postinstall scripts can
  # run, without silently allowing them for every future npm invocation in every repo this
  # tool ever runs. PUPPETEER_SKIP_DOWNLOAD stops Puppeteer's own postinstall from also
  # attempting a Chrome download here — without it, both this install and the explicit
  # `puppeteer browsers install` step below can race on the same cache folder and leave a
  # partially-downloaded, corrupted install ("folder exists but executable is missing").
  PUPPETEER_SKIP_DOWNLOAD=true npm install --dangerously-allow-all-scripts

  if [ -d node_modules/puppeteer ] || [ -d node_modules/puppeteer-core ]; then
    # The single, reliable place Chrome actually gets installed (see PUPPETEER_SKIP_DOWNLOAD
    # above) — needed whether Puppeteer is a direct or transitive dependency. Invoke the local
    # ./node_modules/.bin binary directly rather than `npx puppeteer`: since puppeteer is often
    # only a transitive dependency (not in package.json directly), npx's local-bin resolution
    # isn't guaranteed to find it and can silently fall back to fetching an arbitrary, possibly
    # newer, puppeteer from the registry — which would target a different Chrome build than the
    # pinned version in package-lock.json actually expects at test time.
    echo "==> Installing Puppeteer's Chrome"
    if [ -x ./node_modules/.bin/puppeteer ]; then
      ./node_modules/.bin/puppeteer browsers install chrome
    else
      echo "==> No local puppeteer CLI binary found (puppeteer-core only?) — falling back to npx"
      npx puppeteer browsers install chrome
    fi

    CHROME_BUILD_DIR="$(find "${HOME}/.cache/puppeteer/chrome" -maxdepth 1 -type d -name 'linux-*' 2>/dev/null | head -n1)"
    CHROME_BIN="${CHROME_BUILD_DIR}/chrome-linux64/chrome"

    if [ ! -x "${CHROME_BIN}" ]; then
      # Puppeteer's own bundled zip extraction has been observed leaving an incomplete
      # install here (small files present, large ones like the `chrome` binary itself
      # missing) even though the downloaded zip is complete and valid — confirmed by
      # manually re-extracting the same zip with the system `unzip` binary, which produces
      # a full, correct install. Repair by re-extracting with `unzip` instead of re-downloading.
      CHROME_ZIP="$(find "${HOME}/.cache/puppeteer/chrome" -maxdepth 1 -name '*-chrome-linux64.zip' 2>/dev/null | head -n1)"
      if [ -n "${CHROME_ZIP}" ] && [ -n "${CHROME_BUILD_DIR}" ]; then
        echo "==> Chrome binary missing after puppeteer's own extraction — repairing with unzip"
        # The zip's internal paths already start with chrome-linux64/, so extract into
        # CHROME_BUILD_DIR itself, not CHROME_BUILD_DIR/chrome-linux64 (which would double-nest it).
        unzip -o "${CHROME_ZIP}" -d "${CHROME_BUILD_DIR}"
      fi
    fi

    if [ ! -x "${CHROME_BIN}" ]; then
      echo "==> ERROR: Chrome binary still not found at ${CHROME_BIN} after install and unzip repair." >&2
      exit 1
    fi
    echo "==> Confirmed Chrome binary present: ${CHROME_BIN}"
  fi
fi

if [ -n "${TEST_ONLY:-}" ]; then
  echo "==> TEST_ONLY set — skipping Claude/PR, running npm test only"
  if npm run | grep -qE '^\s*test$'; then
    npm test
  else
    echo "==> No 'test' script defined in package.json, nothing to run"
  fi
  echo "==> Done (test-only)"
  exit 0
fi

echo "==> Configuring git identity and credentials"
git config user.name "${GIT_AUTHOR_NAME}"
git config user.email "${GIT_AUTHOR_EMAIL}"
# gh CLI subcommands pick up GH_TOKEN automatically, but plain `git push` doesn't —
# this wires git's credential helper to shell out to `gh`, which does.
gh auth setup-git

echo "==> Checking out ${BRANCH}"
git checkout -b "${BRANCH}"

echo "==> Fetching issue #${ISSUE_NUMBER}"
ISSUE_BODY="$(gh issue view "${ISSUE_NUMBER}" --repo "${REPO}" --json title,body --jq '"# " + .title + "\n\n" + .body')"

echo "==> Trusting ${WORKDIR} so Claude doesn't prompt or ignore repo settings"
CLAUDE_CONFIG="${HOME}/.claude.json"
[ -f "${CLAUDE_CONFIG}" ] || echo '{}' > "${CLAUDE_CONFIG}"
jq --arg path "${WORKDIR}" '.projects[$path].hasTrustDialogAccepted = true' "${CLAUDE_CONFIG}" > "${CLAUDE_CONFIG}.tmp"
mv "${CLAUDE_CONFIG}.tmp" "${CLAUDE_CONFIG}"

PROMPT="You are working in a clone of ${REPO} on branch ${BRANCH}. Implement the following GitHub issue. Make focused changes, follow existing code conventions, and check package.json for lint/build/test scripts — run whichever are relevant and make sure they pass before finishing. Do not push to ${BASE_BRANCH} directly.

Once you're finished and everything passes, commit your changes with a clear message, run 'git push -u origin ${BRANCH}', and open a pull request against ${BASE_BRANCH} yourself using 'gh pr create'. Write a specific, descriptive title (not just the issue title verbatim), and a body that a reviewer with no other context could use to understand the change: summarize what you changed and why, call out any notable implementation decisions or tradeoffs, and note anything you deliberately left out of scope. Include 'Closes #${ISSUE_NUMBER}' in the body.

${ISSUE_BODY}"

echo "==> Running claude"
stdbuf -oL claude -p "${PROMPT}" --dangerously-skip-permissions --output-format stream-json --verbose --include-partial-messages \
  | format-claude-stream

echo "==> Checking outcome"
PR_URL="$(gh pr list --repo "${REPO}" --head "${BRANCH}" --json url --jq '.[0].url // empty')"

if [ -n "${PR_URL}" ]; then
  echo "==> Agent opened a PR: ${PR_URL}"
elif [ -n "$(git status --porcelain)" ]; then
  echo "==> Agent made changes but didn't finish the git workflow — committing and opening a fallback PR so the work isn't lost"
  git add -A
  git commit -m "Implement #${ISSUE_NUMBER}"
  git push -u origin "${BRANCH}"
  gh pr create \
    --repo "${REPO}" \
    --base "${BASE_BRANCH}" \
    --head "${BRANCH}" \
    --title "Fix #${ISSUE_NUMBER}" \
    --body "Closes #${ISSUE_NUMBER}

Automated fallback PR generated by agent-runner (the agent didn't open one itself)."
else
  echo "==> No changes made, nothing to push"
fi

echo "==> Done"
