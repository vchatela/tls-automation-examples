#!/bin/bash

echo "🚀 HashiCorp Vault Ag# Step 2: Setup PKI and Kubernetes Authentication
echo "🔧 Step 2: Setting up Vault PKI engine and Kubernetes authentication..."
./setup-pki.sh

echo ""
read -p "Press Enter to deploy NGINX with Vault injection..."jector Demo"
echo "======================================"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    echo "💡 Install helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if cluster is available
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not accessible"
    echo "💡 Make sure your cluster is running and kubectl is configured"
    echo "💡 Run: kubectl cluster-info"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Step 1: Install Vault
echo "📦 Step 1: Installing HashiCorp Vault..."
./install-vault.sh

echo ""
read -p "Press Enter to continue with PKI setup..."

# Step 2: Setup PKI and Kubernetes Authentication
echo "� Step 2: Setting up Vault PKI engine and Kubernetes authentication..."
./setup-pki.sh

echo ""
read -p "Press Enter to deploy NGINX with Vault injection..."

# Step 3: Deploy NGINX
echo "🌐 Step 3: Deploying NGINX with Vault Agent Injector..."
kubectl apply -f nginx-vault-deployment.yaml

echo ""
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-vault

echo ""
read -p "Press Enter to run the TLS test..."

# Step 4: Test TLS
echo "🧪 Step 4: Testing Vault-issued TLS certificate..."
./test-vault-tls.sh

echo ""
echo "🎉 Demo completed successfully!"
echo ""
echo "📚 What you've accomplished:"
echo "   ✅ Deployed HashiCorp Vault with Agent Injector"
echo "   ✅ Configured PKI secrets engine with intermediate CA"
echo "   ✅ Set up Kubernetes authentication"
echo "   ✅ Deployed NGINX with automatic certificate injection"
echo "   ✅ Verified TLS certificate issued by Vault"
echo ""
echo "🔄 The certificate will automatically renew before expiration (24h TTL)"
echo ""
echo "🧹 To clean up:"
echo "   ./cleanup.sh"
echo ""
echo "   Or manually:"
echo "   kubectl delete -f nginx-vault-deployment.yaml"
echo "   helm uninstall vault -n vault"
echo "   kubectl delete namespace vault"
