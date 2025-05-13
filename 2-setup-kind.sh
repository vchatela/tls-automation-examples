#!/bin/bash

set -euo pipefail

CLUSTER_NAME="poc-cluster"

echo "🔍 Checking if kind cluster '${CLUSTER_NAME}' exists..."

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "✅ kind cluster '${CLUSTER_NAME}' already exists."
else
  echo "🚀 Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}"
  echo "✅ Cluster '${CLUSTER_NAME}' created successfully."
fi
