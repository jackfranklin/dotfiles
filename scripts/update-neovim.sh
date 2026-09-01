#!/bin/bash
set -euo pipefail

# Argument check
CHECK_ONLY=false
if [ "${1:-}" = "--check" ]; then
  CHECK_ONLY=true
fi

# OS detection
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

# Architecture detection
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

# Setup check helper
resolve_symlink() {
  local target="$1"
  while [ -L "${target}" ]; do
    local link
    link=$(readlink "${target}")
    if [[ "${link}" == /* ]]; then
      target="${link}"
    else
      target="$(dirname "${target}")/${link}"
    fi
  done
  echo "${target}"
}

CURRENT_NVIM=$(command -v nvim || true)
INSTALL_TYPE="none"
RESOLVED_PATH=""
INSTALL_PATH="${HOME}/nvim-github-releases/nvim-${OS}-${ARCH}"

if [ -n "${CURRENT_NVIM}" ]; then
  RESOLVED_PATH=$(resolve_symlink "${CURRENT_NVIM}")
  echo "Found existing Neovim binary in PATH at: ${RESOLVED_PATH}"

  if [[ "${RESOLVED_PATH}" == *"/nvim-github-releases/nvim-"* ]]; then
    INSTALL_TYPE="standalone"
    INSTALL_PATH=$(dirname "$(dirname "${RESOLVED_PATH}")")
  elif [[ "${RESOLVED_PATH}" == *"/squashfs-root/usr/bin/nvim" ]]; then
    INSTALL_TYPE="appimage_extract"
    INSTALL_PATH=$(dirname "$(dirname "$(dirname "${RESOLVED_PATH}")")")
  else
    INSTALL_TYPE="external"
  fi
fi

if [ "${INSTALL_TYPE}" = "external" ]; then
  echo "Neovim is installed at ${RESOLVED_PATH}, which appears to be managed by a package manager or custom installation."
  echo "Skipping automated GitHub release update to avoid conflicts."
  exit 0
fi

echo "Checking current Neovim version..."
if [ -n "${RESOLVED_PATH}" ] && [ -f "${RESOLVED_PATH}" ]; then
  CURRENT_VERSION=$("${RESOLVED_PATH}" --version | head -n 1 | awk '{print $2}')
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

if [ "${CHECK_ONLY}" = true ]; then
  echo "PLAN:"
  if [ "${INSTALL_TYPE}" = "none" ]; then
    echo "- Action: Fresh install of standalone Neovim version ${LATEST_VERSION}"
    echo "- Method: Download and extract tarball"
    echo "- Destination: ${INSTALL_PATH}"
  elif [ "${INSTALL_TYPE}" = "standalone" ]; then
    echo "- Action: Update standalone Neovim from ${CURRENT_VERSION} to ${LATEST_VERSION}"
    echo "- Method: Download and extract tarball"
    echo "- Destination: ${INSTALL_PATH}"
  elif [ "${INSTALL_TYPE}" = "appimage_extract" ]; then
    echo "- Action: Update extracted AppImage Neovim from ${CURRENT_VERSION} to ${LATEST_VERSION}"
    echo "- Method: Download and extract AppImage (--appimage-extract)"
    echo "- Destination: ${INSTALL_PATH}"
  fi
  exit 0
fi

TEMP_DIR=$(mktemp -d)
# Cleanup on exit
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

if [ "${INSTALL_TYPE}" = "appimage_extract" ]; then
  DOWNLOAD_FILE="nvim-linux-${ARCH}.appimage"
  DOWNLOAD_URL=$(echo "${LATEST_RELEASE_JSON}" | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep "${DOWNLOAD_FILE}" | head -n 1)

  if [ -z "${DOWNLOAD_URL}" ]; then
    echo "Error: Could not find download URL for ${DOWNLOAD_FILE}."
    exit 1
  fi

  echo "Downloading ${LATEST_VERSION} AppImage from ${DOWNLOAD_URL}..."
  curl -sL "${DOWNLOAD_URL}" -o "${TEMP_DIR}/${DOWNLOAD_FILE}"
  chmod +x "${TEMP_DIR}/${DOWNLOAD_FILE}"

  echo "Extracting AppImage..."
  (cd "${TEMP_DIR}" && "./${DOWNLOAD_FILE}" --appimage-extract)
  NEW_NVIM_BIN="${TEMP_DIR}/squashfs-root/usr/bin/nvim"
else
  # Default to standalone tarball
  DOWNLOAD_FILE="nvim-${OS}-${ARCH}.tar.gz"
  DOWNLOAD_URL=$(echo "${LATEST_RELEASE_JSON}" | grep -o '"browser_download_url": "[^"]*' | grep -o '[^"]*$' | grep "${DOWNLOAD_FILE}" | head -n 1)

  if [ -z "${DOWNLOAD_URL}" ]; then
    echo "Error: Could not find download URL for ${DOWNLOAD_FILE}."
    exit 1
  fi

  echo "Downloading ${LATEST_VERSION} tarball from ${DOWNLOAD_URL}..."
  curl -sL "${DOWNLOAD_URL}" -o "${TEMP_DIR}/${DOWNLOAD_FILE}"

  echo "Extracting tarball..."
  tar -C "${TEMP_DIR}" -xzf "${TEMP_DIR}/${DOWNLOAD_FILE}"
  NEW_NVIM_BIN="${TEMP_DIR}/nvim-${OS}-${ARCH}/bin/nvim"
fi

if [ ! -f "${NEW_NVIM_BIN}" ]; then
  echo "Error: Extracted binary was not found at ${NEW_NVIM_BIN}"
  exit 1
fi

# Verify the new binary works
echo "Verifying new binary..."
NEW_VERSION=$("${NEW_NVIM_BIN}" --version | head -n 1 | awk '{print $2}')
echo "Verified version: ${NEW_VERSION}"

# Swap directories
echo "Installing new version..."
PARENT_DIR=$(dirname "${INSTALL_PATH}")
mkdir -p "${PARENT_DIR}"
BACKUP_DIR="${INSTALL_PATH}-backup"

if [ -d "${INSTALL_PATH}" ]; then
  rm -rf "${BACKUP_DIR}"
  mv "${INSTALL_PATH}" "${BACKUP_DIR}"
fi

if [ "${INSTALL_TYPE}" = "appimage_extract" ]; then
  mv "${TEMP_DIR}/squashfs-root" "${INSTALL_PATH}"
else
  mv "${TEMP_DIR}/nvim-${OS}-${ARCH}" "${INSTALL_PATH}"
fi

rm -rf "${BACKUP_DIR}"

echo "Successfully updated Neovim from ${CURRENT_VERSION} to ${NEW_VERSION}!"
