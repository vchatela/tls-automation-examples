#!/bin/bash
# Script to setup Ansible Vault for secure API key storage

set -euo pipefail

echo "🔐 Setting up Ansible Vault for Venafi API Key"
echo "=============================================="
echo ""

# Check if vault.yml already exists
if [ -f "vault.yml" ]; then
    echo "⚠️  vault.yml already exists!"
    echo ""
    read -p "Do you want to edit the existing vault? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Opening vault for editing..."
        ansible-vault edit vault.yml
        exit 0
    else
        echo "Vault setup cancelled."
        exit 0
    fi
fi

echo "This script will create an encrypted vault.yml file to store your Venafi API key securely."
echo ""

# Get API key from user
if [ -n "${VCERT_APIKEY:-}" ]; then
    echo "Found VCERT_APIKEY in environment."
    read -p "Use this API key for the vault? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        read -p "Enter your Venafi API key: " -s api_key
        echo
    else
        api_key="$VCERT_APIKEY"
    fi
else
    echo "Enter your Venafi API key (from https://eval-61683418.venafi.cloud/):"
    read -p "API Key: " -s api_key
    echo
fi

if [ -z "$api_key" ]; then
    echo "❌ No API key provided. Exiting."
    exit 1
fi

# Create temporary vault content
cat > vault_temp.yml << EOF
---
# Venafi as a Service API Key
# This file is encrypted with Ansible Vault
vault_venafi_api_key: "$api_key"

# Add other sensitive variables here as needed
# vault_other_secret: "value"
EOF

echo ""
echo "Creating encrypted vault..."
echo "You will be prompted to create a vault password. Remember this password!"
echo ""

# Encrypt the vault
if ansible-vault encrypt vault_temp.yml --output vault.yml; then
    rm -f vault_temp.yml
    echo ""
    echo "✅ Vault created successfully as vault.yml"
    echo ""
    echo "📝 Important notes:"
    echo "- vault.yml is encrypted and safe to store (but excluded from git)"
    echo "- Remember your vault password - you'll need it to run playbooks"
    echo "- To edit the vault later: ansible-vault edit vault.yml"
    echo "- To change vault password: ansible-vault rekey vault.yml"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Run playbooks with: ansible-playbook --ask-vault-pass -i hosts.ini playbook.yml"
    echo "2. Or create .vault_pass file with your password (add to .gitignore)"
    echo "3. Then run: ansible-playbook --vault-password-file .vault_pass -i hosts.ini playbook.yml"
else
    rm -f vault_temp.yml
    echo "❌ Failed to create vault"
    exit 1
fi
