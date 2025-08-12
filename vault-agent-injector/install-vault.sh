#!/bin/bash

echo "🔍 Installing HashiCorp Vault..."

# Add HashiCorp Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Create vault namespace
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

# Install Vault with development mode and agent injector enabled
helm install vault hashicorp/vault \
  --namespace vault \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=root-token" \
  --set "injector.enabled=true" \
  --set "injector.agentImage.repository=hashicorp/vault" \
  --set "injector.agentImage.tag=1.20.1" \
  --set "csi.enabled=false"

echo "✅ Vault installation initiated"
echo "📝 Root token: root-token"
echo ""
echo "Waiting for Vault to be ready..."

# Wait for pods to be created first
echo "🔄 Waiting for pods to be created..."
while ! kubectl get pods -n vault 2>/dev/null | grep -q vault; do
  echo "   Pods not yet created, waiting 5 seconds..."
  sleep 5
done

# Now wait for them to be ready
echo "🔄 Waiting for Vault pods to be ready..."
if kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=300s 2>/dev/null; then
  echo "✅ Vault pods are ready!"
else
  echo "⚠️  Timeout or pods not found, checking status..."
  kubectl get pods -n vault
  echo "💡 Note: Pods may still be starting. Check the status above."
fi

echo ""
echo "🎯 Vault is ready! Check status with:"
echo "   kubectl get pods -n vault"
echo "   kubectl logs -f vault-0 -n vault"
