#!/bin/bash

echo "🔧 Configuring Vault PKI engine..."

# Set Vault address and token (using port-forward)
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="root-token"

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up port forward..."
    # Kill any port forwards to vault
    pkill -f "kubectl port-forward.*vault.*8200" 2>/dev/null || true
    # Also kill by PID if we have it
    if [ ! -z "$VAULT_PF_PID" ]; then
        kill $VAULT_PF_PID 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Port forward to Vault in the background
echo "🔌 Setting up port forwarding to Vault..."
# Kill any existing port forwards first
pkill -f "kubectl port-forward.*vault.*8200" 2>/dev/null || true
sleep 2

kubectl port-forward -n vault vault-0 8200:8200 &
VAULT_PF_PID=$!

# Wait for port forward to be ready
sleep 5

# Enable PKI secrets engine
echo "📝 Enabling PKI secrets engine..."
vault secrets enable pki

# Configure PKI engine TTL
vault secrets tune -max-lease-ttl=87600h pki

# Generate root CA certificate
echo "🔐 Generating root CA certificate..."
vault write -field=certificate pki/root/generate/internal \
    common_name="Demo Root CA" \
    ttl=87600h > root_ca.crt

# Configure CA and CRL URLs
vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Enable intermediate PKI
echo "🔗 Setting up intermediate PKI..."
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int

# Generate intermediate CSR
vault write -format=json pki_int/intermediate/generate/internal \
    common_name="Demo Intermediate CA" \
    | jq -r '.data.csr' > pki_intermediate.csr

# Sign intermediate certificate
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
    format=pem_bundle ttl="43800h" \
    | jq -r '.data.certificate' > intermediate.cert.pem

# Set signed certificate
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

# Create a role for issuing certificates
echo "⚙️ Creating PKI role..."
vault write pki_int/roles/tls-server \
    allowed_domains="example.com,local" \
    allow_subdomains=true \
    allow_localhost=true \
    allow_ip_sans=true \
    max_ttl="768h"

# Enable Kubernetes auth method
echo "🔑 Setting up Kubernetes authentication..."
vault auth enable kubernetes

# Configure Kubernetes auth
# First, we need to get the cluster info from kubectl since we're running outside the cluster
K8S_HOST=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')

# Get the correct CA certificate from a running pod's service account (not kubectl config)
echo "📝 Getting correct CA certificate from cluster..."
# Create a temporary pod to get the actual CA cert used by service accounts
kubectl run temp-ca-pod --image=busybox --restart=Never --rm -i --quiet -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt > /tmp/k8s_ca.crt 2>/dev/null
K8S_CA_CERT=$(cat /tmp/k8s_ca.crt)
rm -f /tmp/k8s_ca.crt

# Create a temporary service account token for configuration
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth-secret
  namespace: vault
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF

# Create RBAC for vault service account to review tokens
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-tokenreview-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault
  namespace: vault
EOF

# Wait a moment for the resources to be created
sleep 3

# Get a fresh service account token (this is the key fix!)
SA_JWT_TOKEN=$(kubectl create token vault -n vault)

# Get Kubernetes API server internal endpoint (cluster IP)
K8S_HOST="https://$(kubectl get svc kubernetes -o jsonpath='{.spec.clusterIP}:{.spec.ports[0].port}')"
echo "🔍 Kubernetes API server (internal): $K8S_HOST"

# Configure Kubernetes auth with the correct parameters
vault write auth/kubernetes/config \
    token_reviewer_jwt="$SA_JWT_TOKEN" \
    kubernetes_host="$K8S_HOST" \
    kubernetes_ca_cert="$K8S_CA_CERT" \
    disable_iss_validation=true

# Create policy for PKI access
echo "📋 Creating Vault policy..."
vault policy write pki-policy - <<EOF
path "pki_int/issue/tls-server" {
  capabilities = ["create", "update"]
}
path "pki_int/certs" {
  capabilities = ["list"]
}
path "pki_int/revoke" {
  capabilities = ["create", "update"]
}
path "pki_int/tidy" {
  capabilities = ["create", "update"]
}
path "pki/cert/ca" {
  capabilities = ["read"]
}
path "auth/token/renew" {
  capabilities = ["update"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF

# Create Kubernetes role
echo "👤 Creating Kubernetes role..."
vault write auth/kubernetes/role/pki-role \
    bound_service_account_names=vault-pki \
    bound_service_account_namespaces=default \
    policies=pki-policy \
    ttl=24h

echo "✅ Vault PKI configuration completed!"
echo ""

# Create the service account for nginx deployment
echo "🔑 Creating Kubernetes service account for nginx deployment..."
kubectl apply -f vault-auth.yaml

echo ""
echo "📊 Configuration summary:"
echo "   - Root CA: Demo Root CA"
echo "   - Intermediate CA: Demo Intermediate CA"
echo "   - PKI Role: tls-server"
echo "   - Max TTL: 768h (32 days)"
echo "   - Policy: pki-policy"
echo "   - K8s Role: pki-role"
echo "   - Service Account: vault-pki (created)"
echo ""
echo "🎯 Next steps:"
echo "   1. Deploy NGINX with Vault injection: kubectl apply -f nginx-vault-deployment.yaml"

# Clean up temporary files and resources
rm -f pki_intermediate.csr intermediate.cert.pem
kubectl delete secret vault-auth-secret -n vault --ignore-not-found=true
