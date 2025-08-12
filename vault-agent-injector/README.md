# HashiCorp Vault Agent Injector with PKI Engine
This example demonstrates how to use **HashiCorp Vault** with the **Vault Agent Injector** to automate TLS certificate issuance and injection into Kubernetes pods. This approach leverages Vault's PKI secrets engine to issue short-lived certificates that are automatically injected into application containers.

---

## 📁 Contents

| Use Case                       | Tooling        | Files                                               | Description                                                    |
| ------------------------------ | -------------- | --------------------------------------------------- | -------------------------------------------------------------- |
| ✅ Vault PKI Setup             | `vault`, `helm` | `install-vault.sh`, `setup-pki.sh`                 | Deploy Vault and configure PKI secrets engine                 |
| ✅ Certificate Injection        | Vault Agent    | `vault-auth.yaml`, `vault-pki-role.yaml`           | Configure authentication and PKI role for certificate issuance |
| ✅ HTTPS service example        | `nginx` + TLS  | `nginx-vault-deployment.yaml`                      | Serves HTTPS with Vault-injected certs using Agent Injector   |

---

## 🧩 Prerequisites
* Kubernetes cluster (setup with `1-prepapre-kind.sh` and `2-setup-kind.sh`)
* Helm installed
* kubectl configured for the cluster

---

## 🚀 Use Case: Certificate Injection via Vault Agent

This section shows how to configure HashiCorp Vault with PKI engine and use Vault Agent Injector to automatically provide TLS certificates to applications.

### 📦 Step 1: Install HashiCorp Vault

Deploy Vault using the official Helm chart:

```bash
chmod +x install-vault.sh
./install-vault.sh
```

Wait for Vault to be ready:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=300s
```

### 🔐 Step 2: Initialize and Configure Vault

Initialize Vault and configure the PKI secrets engine:

```bash
chmod +x setup-pki.sh
./setup-pki.sh
```

This script will:
- Initialize Vault with an unseal key and root token
- Enable the PKI secrets engine
- Configure a root CA certificate
- Create an intermediate CA
- Set up certificate roles for different use cases

### 🔑 Step 3: Configure Kubernetes Authentication

Apply the Kubernetes authentication configuration:

```bash
kubectl apply -f vault-auth.yaml
```

### 🧾 Step 4: Create PKI Role and Policy

Configure the PKI role and policy for certificate issuance:

```bash
kubectl apply -f vault-pki-role.yaml
```

### 🌐 Step 5: Deploy NGINX with Vault Agent Injector

Deploy the NGINX application with Vault Agent Injector annotations:

```bash
kubectl apply -f nginx-vault-deployment.yaml
```

The Vault Agent Injector will automatically:
- Authenticate with Vault using the service account
- Request a TLS certificate from the PKI engine
- Inject the certificate and key into the pod
- Continuously renew the certificate before expiration

### ✅ Step 6: Test the TLS Connection

Forward the HTTPS port:

```bash
kubectl port-forward svc/nginx-vault 8443:443
```

In another terminal, test the TLS connection:

```bash
curl -k https://localhost:8443
```

**Expected Output:**
```
Hello from HashiCorp Vault TLS!
Certificate issued by Vault PKI Engine
TTL: 24 hours
```

### 🔍 Verify Certificate Details

Check the certificate details to see the Vault-issued certificate:

```bash
POD_NAME=$(kubectl get pod -l app=nginx-vault -o jsonpath="{.items[0].metadata.name}")
kubectl exec $POD_NAME -- openssl x509 -in /vault/secrets/tls.crt -noout -text
```

**Example Output:**
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            5e:52:0f:e1:37:aa:d9:1b:2d:05:ff:62:1a:e4:43:64:68:56:12:c5
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = Demo Intermediate CA
        Validity
            Not Before: Aug 12 11:20:06 2025 GMT
            Not After : Aug 13 11:20:36 2025 GMT
        Subject: CN = nginx-vault.local
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
```

### 🔍 Monitoring Certificate Rotation

**Successful Vault Agent Logs:**
```bash
kubectl logs $POD_NAME -c vault-agent --tail=10
```

**Example Success Logs:**
```
2025-08-12T11:20:36.164Z [INFO]  agent.sink.file: token written: path=/home/vault/.vault-token
2025-08-12T11:20:36.164Z [INFO]  agent: (runner) creating watcher
2025-08-12T11:20:36.164Z [INFO]  agent: (runner) starting
2025-08-12T11:20:36.166Z [INFO]  agent.auth.handler: renewed auth token
2025-08-12T11:20:36.167Z [INFO]  agent.apiproxy: received request: method=GET path=/v1/sys/internal/ui/mounts/pki_int/issue/tls-server
2025-08-12T11:20:36.169Z [INFO]  agent.apiproxy: received request: method=PUT path=/v1/pki_int/issue/tls-server
2025-08-12T11:20:36.515Z [INFO]  agent: (runner) rendered "(dynamic)" => "/vault/secrets/tls.crt"
2025-08-12T11:20:36.515Z [INFO]  agent: (runner) rendered "(dynamic)" => "/vault/secrets/tls.key"
```

**Monitor Certificate Files:**
```bash
# Check that certificates are injected
kubectl exec $POD_NAME -- ls -la /vault/secrets/
```

**Expected Output:**
```
total 12
drwxrwxrwt 2 root root   80 Aug 12 11:20 .
drwxr-xr-x 3 root root 4096 Aug 12 11:20 ..
-rw-r--r-- 1  100 1000 1223 Aug 12 11:20 tls.crt
-rw-r--r-- 1  100 1000 1674 Aug 12 11:20 tls.key
```

**Watch for Certificate Rotation:**
```bash
# Certificates are renewed automatically (24h TTL)
watch -n 30 "kubectl exec $POD_NAME -- openssl x509 -in /vault/secrets/tls.crt -noout -dates"
```

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Application   │    │  Vault Agent     │    │  HashiCorp      │
│     Pod         │    │   Injector       │    │    Vault        │
│                 │    │                  │    │                 │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ ┌─────────────┐ │
│ │    NGINX    │ │    │ │ Agent Sidecar│ │    │ │ PKI Engine  │ │
│ │             │ │◄───┤ │              │ │◄───┤ │             │ │
│ │ /vault/     │ │    │ │ - Auth       │ │    │ │ - Root CA   │ │
│ │ secrets/    │ │    │ │ - Cert Req   │ │    │ │ - Inter CA  │ │
│ │ tls.crt     │ │    │ │ - Renewal    │ │    │ │ - Roles     │ │
│ │ tls.key     │ │    │ └──────────────┘ │    │ └─────────────┘ │
│ └─────────────┘ │    └──────────────────┘    └─────────────────┘
└─────────────────┘
```

**Key Benefits:**
- **Automatic Certificate Lifecycle**: Vault Agent handles issuance, renewal, and rotation
- **Short-lived Certificates**: Reduces security risk with configurable TTL
- **Zero-touch Deployment**: No manual certificate management required
- **Kubernetes Native**: Integrates seamlessly with K8s RBAC and service accounts

---

## � Troubleshooting

## 🔧 Troubleshooting

### Common Issues and Solutions

**1. Vault Agent Injector not injecting certificates**

*Symptoms:* Pod stuck in `Init:0/1` status, logs show `permission denied`

*Root Cause:* Most commonly, this is due to Vault being configured with the wrong CA certificate. The CA certificate from kubectl config may differ from the actual CA used by service accounts in the cluster.

*Solution:*
```bash
# Get the correct CA cert from a pod's service account (not kubectl config)
kubectl run temp-ca-pod --image=busybox --restart=Never --rm -i --quiet -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt > k8s_ca.crt

# Reconfigure Vault with the correct CA
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="root-token"
kubectl port-forward -n vault vault-0 8200:8200 &

SA_JWT_TOKEN=$(kubectl get secret vault-auth-secret -n vault -o jsonpath="{.data.token}" | base64 -d)
vault write auth/kubernetes/config \
    token_reviewer_jwt="$SA_JWT_TOKEN" \
    kubernetes_host="https://10.96.0.1:443" \
    kubernetes_ca_cert="$(cat k8s_ca.crt)" \
    disable_iss_validation=true

# Clean up
rm k8s_ca.crt
```

**2. Authentication errors - Example logs and solutions**

*Error logs you might see:*
```
2025-08-12T11:02:07.848Z [ERROR] agent.auth.handler: error authenticating:
  error=
  | Error making API request.
  | URL: PUT http://vault.vault.svc:8200/v1/auth/kubernetes/login
  | Code: 403. Errors:
  | * permission denied
```

*Solutions:*
```bash
# Verify RBAC is correctly configured
kubectl auth can-i create tokenreviews --as=system:serviceaccount:vault:vault

# Check the Vault role configuration
vault read auth/kubernetes/role/pki-role

# Verify service account exists
kubectl get serviceaccount vault-pki
```

**3. Successful deployment indicators**

*What success looks like:*
```bash
$ kubectl get pods -l app=nginx-vault
NAME                           READY   STATUS    RESTARTS   AGE
nginx-vault-7f77545b6c-h7szx   2/2     Running   0          3m48s

$ kubectl exec $POD_NAME -- ls -la /vault/secrets/
total 12
drwxrwxrwt 2 root root   80 Aug 12 11:20 .
drwxr-xr-x 3 root root 4096 Aug 12 11:20 ..
-rw-r--r-- 1  100 1000 1223 Aug 12 11:20 tls.crt
-rw-r--r-- 1  100 1000 1674 Aug 12 11:20 tls.key
```

**4. Port forwarding conflicts**

*Symptoms:* 
```
Unable to listen on port 8200: Listeners failed to create with the following errors: 
[unable to create listener: Error listen tcp4 127.0.0.1:8200: bind: address already in use]
```

*Solution:*
```bash
# Use the provided cleanup script
./kill-port-forwards.sh

# Or manually kill port forwards
pkill -f "kubectl port-forward.*vault.*8200"
pkill -f "kubectl port-forward.*nginx-vault.*8443"

# Check what's using the ports
lsof -i:8200 2>/dev/null || echo "Port 8200 is free"
lsof -i:8443 2>/dev/null || echo "Port 8443 is free"
```

### Quick Demo

For a complete end-to-end demo, run:
```bash
./demo.sh
```

To clean up everything:
```bash
./cleanup.sh
```

---

## �🔗 References

* [📘 Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector)
* [🔐 Vault PKI Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/pki)
* [⚙️ Vault Kubernetes Auth](https://developer.hashicorp.com/vault/docs/auth/kubernetes)
* [📊 Vault Helm Chart](https://github.com/hashicorp/vault-helm)
