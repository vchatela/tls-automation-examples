#!/bin/bash

echo "🧹 Cleaning up HashiCorp Vault Agent Injector demo..."
echo ""

# Kill any running port forwards first
echo "🔌 Stopping port forwards..."
pkill -f "kubectl port-forward.*vault.*8200" 2>/dev/null || true
pkill -f "kubectl port-forward.*nginx-vault.*8443" 2>/dev/null || true
sleep 2

# Remove NGINX deployment
echo "🗑️ Removing NGINX deployment..."
kubectl delete -f nginx-vault-deployment.yaml --ignore-not-found=true

# Remove Kubernetes auth resources
echo "🗑️ Removing Kubernetes authentication resources..."
kubectl delete -f vault-auth.yaml --ignore-not-found=true

# Remove additional RBAC we created
echo "🗑️ Removing additional RBAC resources..."
kubectl delete clusterrolebinding vault-tokenreview-binding --ignore-not-found=true
kubectl delete secret vault-auth-secret -n vault --ignore-not-found=true

# Uninstall Vault
echo "🗑️ Uninstalling Vault..."
helm uninstall vault -n vault --ignore-not-found=true

# Remove vault namespace
echo "🗑️ Removing vault namespace..."
kubectl delete namespace vault --ignore-not-found=true

# Remove any temporary files
echo "🗑️ Removing temporary files..."
rm -f root_ca.crt pki_intermediate.csr intermediate.cert.pem k8s_ca.crt pod_ca.crt kubectl_ca.crt

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "🔍 Verify cleanup:"
echo "   kubectl get pods -n vault"
echo "   kubectl get pods -l app=nginx-vault"
echo "   helm list -n vault"
echo "   ps aux | grep 'kubectl port-forward' | grep -v grep"
