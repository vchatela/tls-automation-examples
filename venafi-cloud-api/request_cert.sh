#!/usr/bin/env bash

set -euo pipefail

# The vcert command and its parameters are shown in "DevOps Tools" tabs when opening the Application you created

# Config
API_KEY="${VCERT_APIKEY:-}"
URL="https://api.venafi.eu/"
ZONE="tls-demo-venafi-1\Default"
CN="tls-demo-venafi-1.vchatela.local"
CERT_FILE="cert.pem"
KEY_FILE="key.pem"
CHAIN_FILE="chain.pem"

if [[ -z "$API_KEY" ]]; then
  echo "Error: VCERT_APIKEY is not set"
  exit 1
fi

# Request cert (API_KEY is optionnal as set in variable)
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
