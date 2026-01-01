#!/usr/bin/env bash
#
# Session Start Hook: Install Beads (bd) if not present
# This hook is for Claude Code on the web where bd isn't pre-installed.
# Local Claude Code users should install bd via: npm install -g @beads/bd
#

set -e

BEADS_VERSION="0.41.0"

# Check if bd is already installed
if command -v bd &> /dev/null; then
    exit 0
fi

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# Download and install
DOWNLOAD_URL="https://github.com/steveyegge/beads/releases/download/v${BEADS_VERSION}/beads_${BEADS_VERSION}_${OS}_${ARCH}.tar.gz"
TMP_DIR=$(mktemp -d)

curl -fsSL -o "$TMP_DIR/beads.tar.gz" "$DOWNLOAD_URL"
tar -xzf "$TMP_DIR/beads.tar.gz" -C "$TMP_DIR"

# Install to /usr/local/bin (requires sudo in some environments)
if [[ -w /usr/local/bin ]]; then
    mv "$TMP_DIR/bd" /usr/local/bin/bd
else
    sudo mv "$TMP_DIR/bd" /usr/local/bin/bd
fi
chmod +x /usr/local/bin/bd

rm -rf "$TMP_DIR"

echo "Installed beads v${BEADS_VERSION}"
