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
)

echo "Installing global npm packages..."
npm install --global "${PACKAGES[@]}"
