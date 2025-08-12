#!/bin/bash

echo "🧪 Testing Vault-issued TLS certificate..."

# Check if nginx-vault deployment is ready
echo "🔍 Checking deployment status..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-vault

# Get pod name
POD_NAME=$(kubectl get pod -l app=nginx-vault -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
    echo "❌ No nginx-vault pod found"
    exit 1
fi

echo "📋 Pod: $POD_NAME"

# Check if Vault Agent has injected the certificates
echo "🔍 Checking for injected certificates..."
kubectl exec $POD_NAME -- ls -la /vault/secrets/ || {
    echo "❌ No certificates found in /vault/secrets/"
    echo "💡 Check Vault Agent logs:"
    echo "   kubectl logs $POD_NAME -c vault-agent"
    exit 1
}

# Display certificate information
echo ""
echo "📜 Certificate details:"
kubectl exec $POD_NAME -- openssl x509 -in /vault/secrets/tls.crt -noout -text | grep -E "(Subject:|Issuer:|Not Before:|Not After:|DNS:|Subject Alternative Name)"

# Test HTTPS connection
echo ""
echo "🌐 Testing HTTPS connection..."

# Kill any existing port forwards to avoid conflicts
pkill -f "kubectl port-forward.*nginx-vault.*8443" 2>/dev/null || true
sleep 2

# Port forward in background
kubectl port-forward svc/nginx-vault 8443:443 &
PF_PID=$!

# Function to cleanup port forward
cleanup() {
    echo "🧹 Cleaning up port forward..."
    kill $PF_PID 2>/dev/null || true
    pkill -f "kubectl port-forward.*nginx-vault.*8443" 2>/dev/null || true
}
trap cleanup EXIT

# Wait for port forward to be ready
sleep 3

# Test the connection
echo "🔗 Testing connection to https://localhost:8443"
curl -k -s https://localhost:8443 || {
    echo "❌ HTTPS connection failed"
    echo "💡 Check nginx logs:"
    echo "   kubectl logs $POD_NAME -c nginx"
    exit 1
}

echo ""
echo "🔒 TLS connection details:"
curl -vk https://localhost:8443 2>&1 | grep -E "(Server certificate:|subject:|start date:|expire date:|issuer:)"

echo ""
echo "✅ Vault TLS certificate test completed successfully!"
echo ""
echo "📚 Additional tests you can run:"
echo "   - Check certificate rotation: watch -n 30 \"kubectl exec $POD_NAME -- openssl x509 -in /vault/secrets/tls.crt -noout -dates\""
echo "   - View Vault Agent logs: kubectl logs $POD_NAME -c vault-agent"
echo "   - View nginx logs: kubectl logs $POD_NAME -c nginx"
echo "   - Access cert info endpoint: curl -k https://localhost:8443/cert-info"
