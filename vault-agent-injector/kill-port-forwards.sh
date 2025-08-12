#!/bin/bash

echo "🔍 Checking for active port forwards..."

# Check for vault port forwards
VAULT_PF=$(ps aux | grep 'kubectl port-forward.*vault.*8200' | grep -v grep)
if [ ! -z "$VAULT_PF" ]; then
    echo "Found Vault port forward processes:"
    echo "$VAULT_PF"
    echo "Killing them..."
    pkill -f "kubectl port-forward.*vault.*8200"
fi

# Check for nginx port forwards
NGINX_PF=$(ps aux | grep 'kubectl port-forward.*nginx-vault.*8443' | grep -v grep)
if [ ! -z "$NGINX_PF" ]; then
    echo "Found nginx-vault port forward processes:"
    echo "$NGINX_PF"
    echo "Killing them..."
    pkill -f "kubectl port-forward.*nginx-vault.*8443"
fi

# Check what's using port 8200
PORT_8200=$(lsof -ti:8200 2>/dev/null)
if [ ! -z "$PORT_8200" ]; then
    echo "Found processes using port 8200:"
    lsof -i:8200
    echo "Killing them..."
    kill $PORT_8200 2>/dev/null || true
fi

# Check what's using port 8443
PORT_8443=$(lsof -ti:8443 2>/dev/null)
if [ ! -z "$PORT_8443" ]; then
    echo "Found processes using port 8443:"
    lsof -i:8443
    echo "Killing them..."
    kill $PORT_8443 2>/dev/null || true
fi

echo "✅ Port forward cleanup completed"
echo ""
echo "Verification:"
ps aux | grep 'kubectl port-forward' | grep -v grep || echo "No port forwards running"
