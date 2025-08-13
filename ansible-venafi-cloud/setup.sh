#!/bin/bash
# Quick setup script for Ansible + Venafi Cloud automation

set -euo pipefail

echo "🚀 Setting up Ansible + Venafi Cloud automation..."
echo ""

# Check if we're in the right directory
if [ ! -f "ansible.cfg" ]; then
    echo "❌ Please run this script from the ansible-venafi-cloud directory"
    exit 1
fi

# Check for API key setup
if [ ! -f "vault.yml" ] && [ -z "${VCERT_APIKEY:-}" ]; then
    echo "🔐 No API key setup detected"
    echo ""
    echo "🔐 Recommended: Use Ansible Vault for secure API key storage"
    echo "   Run: ./setup-vault.sh"
    echo ""
    echo "🔧 Alternative: Set environment variable"
    echo "   export VCERT_APIKEY='your-api-key-here'"
    echo ""
    read -p "Do you want to setup Ansible Vault now? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./setup-vault.sh
        if [ $? -ne 0 ]; then
            echo "❌ Vault setup failed. You can setup API key later"
        fi
    else
        echo "💡 You can setup API key later with: ./setup-vault.sh"
    fi
fi

# Install Ansible if not present
if ! command -v ansible &> /dev/null; then
    echo "📦 Installing Ansible..."
    sudo apt update
    sudo apt install -y ansible python3-pip
fi

# Install Python dependencies for Venafi collection
echo "📦 Installing Python dependencies..."
pip3 install --break-system-packages vcert

# Install required Ansible collections
echo "📦 Installing Ansible collections from requirements.yml..."
if [ -f "requirements.yml" ]; then
    ansible-galaxy collection install -r requirements.yml --force
else
    echo "❌ requirements.yml not found, installing collections individually..."
    ansible-galaxy collection install venafi.machine_identity --force
    ansible-galaxy collection install community.crypto --force
    ansible-galaxy collection install community.general --force
    ansible-galaxy collection install ansible.posix --force
fi

# Test basic setup
echo "🧪 Testing setup..."
if ansible-config view &> /dev/null; then
    echo "✅ Ansible configuration is valid"
else
    echo "❌ Ansible configuration has issues"
fi

# Check if collections are installed
if ansible-galaxy collection list | grep -q venafi.machine_identity; then
    echo "✅ Venafi Machine Identity collection installed"
else
    echo "⚠️  Venafi Machine Identity collection may not be properly installed"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔧 Next steps:"
echo "1. Update hosts.ini with your target servers"
echo "2. Customize group_vars/all.yml with your certificate details"
echo "3. Run your first certificate deployment:"
echo "   ansible-playbook -i hosts.ini playbooks/request-deploy-cert.yml"
echo ""
echo "📚 Available playbooks:"
echo "   - playbooks/request-deploy-cert.yml     (Request and deploy certificates)"
echo "   - playbooks/deploy-nginx-tls.yml        (Configure NGINX with TLS)"
echo "   - playbooks/deploy-multiple-servers.yml (Multi-server deployment)"
echo "   - playbooks/setup-cert-renewal.yml      (Setup automatic renewal)"
echo ""
echo "💡 For local testing, you can use:"
echo "   ansible-playbook -i hosts.ini playbooks/request-deploy-cert.yml --limit localhost"
