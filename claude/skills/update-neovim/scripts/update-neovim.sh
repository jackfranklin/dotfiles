#!/bin/bash
set -euo pipefail

TARGET_DIR="${HOME}/nvim-github-releases"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "${OS}" in
  darwin)
    OS="macos"
    ;;
  linux)
    OS="linux"
    ;;
  *)
    echo "Unsupported OS: ${OS}"
    exit 1
    ;;
esac

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)
    ARCH="x86_64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

ARCHIVE_NAME="nvim-${OS}-${ARCH}.tar.gz"
EXTRACTED_DIR_NAME="nvim-${OS}-${ARCH}"
INSTALL_PATH="${TARGET_DIR}/${EXTRACTED_DIR_NAME}"
TEMP_DIR=$(mktemp -d)

# Cleanup on exit
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "Checking current Neovim version..."
if [ -f "${INSTALL_PATH}/bin/nvim" ]; then
  CURRENT_VERSION=$("${INSTALL_PATH}/bin/nvim" --version | head -n 1 | awk '{print $2}')
else
  CURRENT_VERSION="none"
fi
echo "Current version: ${CURRENT_VERSION}"

echo "Fetching latest Neovim release from GitHub..."
LATEST_RELEASE_JSON=$(curl -sL https://api.github.com/repos/neovim/neovim/releases/latest)
LATEST_VERSION=$(echo "${LATEST_RELEASE_JSON}" | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$')
echo "Latest version: ${LATEST_VERSION}"

if [ "${CURRENT_VERSION}" = "${LATEST_VERSION}" ]; then
  echo "Neovim is already up to date (${CURRENT_VERSION})."
  exit 0
fi

# Find download URL
DOWNLOAD_URL=$(echo "${LATEST_RELEASE_JSON}" | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep "${ARCHIVE_NAME}" | head -n 1)

if [ -z "${DOWNLOAD_URL}" ]; then
  echo "Error: Could not find download URL for ${ARCHIVE_NAME}."
  exit 1
fi

echo "Downloading ${LATEST_VERSION} from ${DOWNLOAD_URL}..."
curl -sL "${DOWNLOAD_URL}" -o "${TEMP_DIR}/${ARCHIVE_NAME}"

echo "Extracting..."
tar -C "${TEMP_DIR}" -xzf "${TEMP_DIR}/${ARCHIVE_NAME}"

NEW_NVIM_BIN="${TEMP_DIR}/${EXTRACTED_DIR_NAME}/bin/nvim"
if [ ! -f "${NEW_NVIM_BIN}" ]; then
  echo "Error: Extracted archive did not contain ${EXTRACTED_DIR_NAME}/bin/nvim"
  exit 1
fi

# Verify the new binary works
echo "Verifying new binary..."
NEW_VERSION=$("${NEW_NVIM_BIN}" --version | head -n 1 | awk '{print $2}')
echo "Verified version: ${NEW_VERSION}"

# Swap directories
echo "Installing new version..."
mkdir -p "${TARGET_DIR}"
BACKUP_DIR="${TARGET_DIR}/${EXTRACTED_DIR_NAME}-backup"

if [ -d "${INSTALL_PATH}" ]; then
  rm -rf "${BACKUP_DIR}"
  mv "${INSTALL_PATH}" "${BACKUP_DIR}"
fi

mv "${TEMP_DIR}/${EXTRACTED_DIR_NAME}" "${INSTALL_PATH}"

# Remove backup if all good
rm -rf "${BACKUP_DIR}"

echo "Successfully updated Neovim from ${CURRENT_VERSION} to ${NEW_VERSION}!"
