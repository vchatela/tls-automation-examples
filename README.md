# TLS Automation Examples

This repository contains a collection of practical TLS certificate automation use cases, designed to help organizations transition away from manual certificate management.

These examples accompany a LinkedIn series by [@Valentin](https://www.linkedin.com/posts/vchatela_%F0%9D%97%A7%F0%9D%97%9F%F0%9D%97%A6-%F0%9D%97%94%F0%9D%98%82%F0%9D%98%81%F0%9D%97%BC%F0%9D%97%BA%F0%9D%97%AE%F0%9D%98%81%F0%9D%97%B6%F0%9D%97%BC%F0%9D%97%BB-%F0%9D%97%99%F0%9D%97%BF%F0%9D%97%BC%F0%9D%97%BA-activity-7328029709252837377-zLnZ/), and demonstrate real tools used to automate short-lived certificate issuance and deployment.

## 📌 Use Cases Covered

| # | Availability | Technology | Product | Comments |
|---|--------------|------------|---------|----------|
| 1 | ✅ | CLM | Venafi Cloud | with `vcert` and `VenafiPS` |
| 2 | ✅ | CLM | EJBCA / Keyfactor | REST API (Python) |
| 3 | ✅ | ACME | certbot | Lightweight cert issuance and deployment on NGINX |
| 4 | ✅ | Kubernetes | cert-manager | Full Ingress + renewal flow and deployment on NGINX |
| 5 | ✅ | DevOps | HashiCorp Vault Agent Injector | Secrets injection in K8s with PKI engine |
| 6 | ✅ | DevOps | Ansible | with Venafi as a Service - Infrastructure-as-Code cert management |
| 7 | ✅ | PQC | EJBCA | Post-Quantum Cryptography (PQC) certificate automation |


Each folder is a standalone, working example including:
- Installation and setup instructions
- Scripts or manifests
- Test deployment to verify certificate installation

## 🛠 Requirements

### Prerequisites
- Linux host (WSL, VM, etc.) to run Kubernetes and scripts
- Docker installed
- (Optional) VS Code with `Remote - WSL` extension


### Initialize the POC
#### Prepare Kind
```bash
$ chmod +x 1-prepapre-kind.sh
$ ./1-prepapre-kind.sh
🔍 Checking and installing Kubernetes tools...
📦 Installing kind (v0.27.0)...
✅ kind installed successfully.
✅ kubectl already installed at /usr/local/bin/kubectl
```
#### Setup Kind
```bash
$ chmod +x 2-setup-kind.sh
$ ./2-setup-kind.sh
🔍 Checking if kind cluster 'poc-cluster' exists...
No kind clusters found.
🚀 Creating kind cluster 'poc-cluster'...
...
✅ Cluster 'poc-cluster' created successfully.
```

You can validate using:
```bash
$ kubectl cluster-info --context kind-poc-cluster
Kubernetes control plane is running at https://127.0.0.1:34469
CoreDNS is running at https://127.0.0.1:34469/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
$ kubectl get nodes
NAME                        STATUS   ROLES           AGE   VERSION
poc-cluster-control-plane   Ready    control-plane   23s   v1.32.2
```

## 📂 Folder Overview

| Folder                   | Description                                         |
|--------------------------|-----------------------------------------------------|
| `venafi-cloud-api`       | Automate TLS certificate requests with Venafi Cloud  |
| `cert-manager-k8s`       | Kubernetes-native TLS automation with cert-manager   |
| `ejbca-rest-python`      | EJBCA REST API for certificate issuance             |
| `acme-certbot`           | Scripted certificate issuance with certbot          |
| `vault-agent-injector`   | HashiCorp Vault PKI with Agent Injector             |
| `ansible-venafi-cloud`   | Infrastructure-as-Code TLS automation with Ansible  |
