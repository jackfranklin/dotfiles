#!/usr/bin/env bash

set -euo pipefail

PACKAGES=(
  "typescript"
  "typescript-language-server"
  "@fsouza/prettierd"
  "@t1ckbase/vscode-langservers-extracted"
  "git-recent"
  "oxlint"
  "oxfmt"
  "@ast-grep/cli"
)

echo "Installing global npm packages..."
npm install --global "${PACKAGES[@]}"
