#!/usr/bin/env bash

set -euo pipefail

# Configurable vcert version
VCERT_VERSION="5.9.0"
VCERT_BIN="/usr/local/bin/vcert"

# Check if vcert is already installed
if ! command -v vcert &> /dev/null; then
  echo "[INFO] vcert not found, installing v${VCERT_VERSION}..."

  TMP_DIR="$(mktemp -d)"
  cd "$TMP_DIR"

  ZIP_URL="https://github.com/Venafi/vcert/releases/download/v${VCERT_VERSION}/vcert_v${VCERT_VERSION}_linux.zip"

  curl -LO "$ZIP_URL"
  unzip "vcert_v${VCERT_VERSION}_linux.zip"
  chmod +x vcert
  sudo mv vcert "$VCERT_BIN"

  echo "[INFO] vcert installed to $VCERT_BIN"
else
  echo "[INFO] vcert is already installed at: $(command -v vcert)"
  vcert --version
fi
