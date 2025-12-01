#!/usr/bin/env bash
set -euo pipefail

# Setup script for google-pse-mcp development: install deps and build
# Usage: ./scripts/setup.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "[setup] Starting setup in $REPO_ROOT"

if ! command -v npm >/dev/null 2>&1; then
  echo "[setup] ERROR: npm not found. Please install Node.js and npm." >&2
  exit 1
fi

# Validate Node.js version (require >= 18)
NODE_VERSION_RAW="$(node --version 2>/dev/null || true)"
if [ -z "$NODE_VERSION_RAW" ]; then
  echo "[setup] ERROR: Node.js not found. Please install Node.js 18+." >&2
  exit 1
fi
# Strip leading 'v' and parse major.minor.patch
NODE_VERSION="${NODE_VERSION_RAW#v}"
NODE_MAJOR="$(echo "$NODE_VERSION" | awk -F. '{print $1}')"
if ! [[ "$NODE_MAJOR" =~ ^[0-9]+$ ]]; then
  echo "[setup] ERROR: Unable to parse Node.js version ($NODE_VERSION_RAW). Please ensure Node.js 18+ is installed." >&2
  exit 1
fi
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "[setup] ERROR: Detected Node.js $NODE_VERSION_RAW. Please upgrade to Node 18+ (or the project's minimum) and re-run setup." >&2
  exit 1
fi

if [ -f package-lock.json ]; then
  echo "[setup] Installing dependencies with npm ci..."
  npm ci
else
  echo "[setup] Installing dependencies with npm install..."
  npm install
fi

echo "[setup] Building TypeScript..."
npm run build

echo "[setup] Marking scripts as executable..."
chmod +x scripts/*.sh || true

echo "[setup] Setup completed successfully."
