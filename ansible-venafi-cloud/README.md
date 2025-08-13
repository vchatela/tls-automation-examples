# 🔐 Ansible + Venafi Cloud Certificate Automation

Simple automation to **request TLS certificates** from **Venafi as a Service (VaaS)** using the official **Venafi Machine Identity collection** for Ansible.

⚡ **Quick Start**: Request a certificate from Venafi Cloud in under 5 minutes!

---

## 🎯 What This Does

✅ **Certificate Request** - Get TLS certificates from Venafi Cloud  

---

## 📝 Example Output: Successful Certificate Request

Below is a real output excerpt from running the playbook `request-cert-only.yml`:

```yaml
TASK [Debug API key configuration] ****************************************
ok: [localhost] => {
  "msg": "API Key configured: Yes\nAPI Key length: 36\nURL: https://api.venafi.eu/\nZone: tls-demo-venafi-1\\Default"
}

TASK [Request certificate from Venafi Cloud using CSR] ********************
ok: [localhost] => (item=None) => {
  "changed": true,
  "cert_path": "/home/youruser/ansible-certs/server.crt",
  "chain_path": "/home/youruser/ansible-certs/server-chain.crt",
  "csr_path": "/home/youruser/ansible-certs/server.csr",
  "privatekey_path": "/home/youruser/ansible-certs/server.key",
  "zone": "tls-demo-venafi-1\\Default"
}

TASK [Display certificate info] *******************************************
ok: [localhost] => {
  "msg": "✅ Certificate requested successfully using CSR!\n📋 Certificate Details:\n- Common Name: tls-demo-venafi-vcert.vchatela.local\n- Private Key Path: /home/youruser/ansible-certs/server.key (YOU control this)\n- CSR Path: /home/youruser/ansible-certs/server.csr\n- Certificate Path: /home/youruser/ansible-certs/server.crt\n- Chain Path: /home/youruser/ansible-certs/server-chain.crt\n\n🔍 Verify certificate:\nopenssl x509 -in /home/youruser/ansible-certs/server.crt -text -noout\n\n🔐 Verify private key matches certificate:\nopenssl x509 -noout -modulus -in /home/youruser/ansible-certs/server.crt | openssl md5\nopenssl rsa -noout -modulus -in /home/youruser/ansible-certs/server.key | openssl md5\n\n💾 Files saved to: /home/youruser/ansible-certs/"
}
```

This demonstrates a successful end-to-end certificate request and file creation using Ansible and the Venafi collection.

---
✅ **Secure API Key Storage** - Ansible Vault encryption for sensitive data  
✅ **Local Certificate Storage** - Saves certificates to your home directory  
✅ **Infrastructure as Code** - Version control your certificate automation  
✅ **Git-Safe** - Sensitive data excluded from repository

---

## 🚀 Quick Start


### 1. Install Dependencies & Collections
```bash
# Run the setup script to install Ansible and required collections
./setup.sh
```

### 2. Setup API Key
First, get your API key from: `https://eval-61683418.venafi.cloud/`
- Go to **Preferences** → **API Keys** → Create new key

Then choose one option:

**Option A: Using Ansible Vault (Recommended - Secure)**
```bash
# Create encrypted vault with API key
./setup-vault.sh

# Optional: Create password file to avoid typing vault password every time
echo "your-vault-password" > .vault-pass
chmod 600 .vault-pass
```

**Option B: Using Environment Variable**
```bash
# Set API key in environment
export VCERT_APIKEY="your-api-key-here"
```

### 3. Configure Your Certificate Details

```bash
# Copy example configuration
cp group_vars/all.yml.example group_vars/all.yml

# Edit configuration (update common_name, organization, etc.)
nano group_vars/all.yml
```

### 4. Request Certificate

**Simple one-command certificate request:**
```bash
# Request certificate from Venafi Cloud
ansible-playbook --ask-vault-pass request-cert-only.yml

# Or using password file (if created)
ansible-playbook --vault-password-file .vault-pass request-cert-only.yml

# Or using environment variable
export VCERT_APIKEY="your-api-key"
ansible-playbook request-cert-only.yml
```

**What this does:**
- ✅ Generates a private key and CSR
- ✅ Requests certificate from Venafi Cloud  
- ✅ Saves certificate files to `~/ansible-certs/`

**Certificate files saved to:**
- `~/ansible-certs/server.key` - Private key
- `~/ansible-certs/server.crt` - Certificate 
- `~/ansible-certs/server.csr` - Certificate signing request
- `~/ansible-certs/server-chain.crt` - Certificate chain

**💡 Tip**: Create a `.vault_pass` file with your vault password and use `--vault-password-file .vault_pass` to avoid typing the password each time.

---

## 🗂️ Available Playbooks

| Playbook | Description |
|----------|-------------|
| `request-cert-only.yml` | Request a certificate from Venafi Cloud and save locally |
| `main.yml` | Complete automation (all steps, if needed) |

---

## 🛠️ Configuration

### API Key Security (Choose One)

**Option 1: Ansible Vault (Recommended)**
```bash
./setup-vault.sh  # Creates encrypted vault.yml
# API key stored as: vault_venafi_api_key
```

**Option 2: Environment Variable**
```bash
export VCERT_APIKEY="your-api-key-here"
```

### Key Variables (group_vars/all.yml)

```yaml
venafi:
  platform: "vaas"
  url: "https://api.venafi.cloud"
  # API key automatically sourced from vault.yml or environment
  api_key: "{{ vault_venafi_api_key | default(lookup('env', 'VCERT_APIKEY')) }}"
  zone: "ansible-demo-app\\Default"

certificate:
  common_name: "myapp.example.com"
  organization: "My Organization"
  # ... customize as needed
```

## 🎯 Key Benefits

✅ **Official Venafi Collection** - Native Ansible integration, no external tools  
✅ **Idempotent Operations** - Safe to run multiple times  
✅ **Multi-Server Support** - Deploy to infrastructure at scale  
✅ **Automated Renewal** - Set-and-forget certificate lifecycle management  
✅ **Infrastructure as Code** - Version control your certificate automation  

---

## 🔗 References

* [📘 Venafi Machine Identity Collection](https://galaxy.ansible.com/ui/repo/published/venafi/machine_identity/)
* [🔧 Venafi Certificate Module Docs](https://galaxy.ansible.com/ui/repo/published/venafi/machine_identity/content/module/venafi_certificate/)
* [🔐 Venafi as a Service Portal](https://eval-61683418.venafi.cloud/)
* [� Ansible Documentation](https://docs.ansible.com/)
