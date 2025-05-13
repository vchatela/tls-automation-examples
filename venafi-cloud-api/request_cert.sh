#!/usr/bin/env bash

set -euo pipefail

# Resolve script directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTEFACTS_DIR="$SCRIPT_DIR/artefacts"

# Ensure artefacts folder exists
mkdir -p "$ARTEFACTS_DIR"

# Config
API_KEY="${VCERT_APIKEY:-}"
URL="https://api.venafi.eu/"
ZONE="tls-demo-venafi-1\\Default"
CN="tls-demo-venafi-vcert.vchatela.local"
CERT_FILE="$ARTEFACTS_DIR/vcert-cert.pem"
KEY_FILE="$ARTEFACTS_DIR/vcert-key.pem"
CHAIN_FILE="$ARTEFACTS_DIR/vcert-chain.pem"

if [[ -z "$API_KEY" ]]; then
  echo "Error: VCERT_APIKEY is not set"
  exit 1
fi

# Request cert
vcert enroll \
    --platform "VCP" \
    --url "$URL" \
    --apiKey "$API_KEY" \
    --zone "$ZONE" \
    --commonName "$CN" \
    --chain-file "$CHAIN_FILE" \
    --key-file "$KEY_FILE" \
    --cert-file "$CERT_FILE"

echo "Certificate issued and saved:"
echo "- Cert: $CERT_FILE"
echo "- Key: $KEY_FILE"
echo "- Chain: $CHAIN_FILE"
