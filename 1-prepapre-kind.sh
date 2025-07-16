#!/bin/bash

set -euo pipefail

KIND_VERSION="v0.29.0"

echo "🔍 Checking and installing Kubernetes tools..."

# Install kind if not already present
if ! command -v kind &>/dev/null; then
  echo "📦 Installing kind (${KIND_VERSION})..."
  if [ "$(uname -m)" = "x86_64" ]; then
    curl -Lo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
    chmod +x /tmp/kind
    sudo mv /tmp/kind /usr/local/bin/kind
    echo "✅ kind installed successfully."
  else
    echo "❌ Unsupported architecture for kind: $(uname -m)"
    exit 1
  fi
else
  echo "✅ kind already installed at $(which kind)"
fi

# Install kubectl if not already present
if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl..."
  latest_version=$(curl -sL https://dl.k8s.io/release/stable.txt)
  curl -Lo /tmp/kubectl "https://dl.k8s.io/release/${latest_version}/bin/linux/amd64/kubectl"
  chmod +x /tmp/kubectl
  sudo mv /tmp/kubectl /usr/local/bin/kubectl
  echo "✅ kubectl installed successfully."
else
  echo "✅ kubectl already installed at $(which kubectl)"
fi
