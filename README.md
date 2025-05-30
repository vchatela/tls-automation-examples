# TLS Automation Examples

This repository contains a collection of practical TLS certificate automation use cases, designed to help organizations transition away from manual certificate management.

These examples accompany a LinkedIn series by [@Valentin](https://www.linkedin.com/posts/vchatela_%F0%9D%97%A7%F0%9D%97%9F%F0%9D%97%A6-%F0%9D%97%94%F0%9D%98%82%F0%9D%98%81%F0%9D%97%BC%F0%9D%97%BA%F0%9D%97%AE%F0%9D%98%81%F0%9D%97%B6%F0%9D%97%BC%F0%9D%97%BB-%F0%9D%97%99%F0%9D%97%BF%F0%9D%97%BC%F0%9D%97%BA-activity-7328029709252837377-zLnZ/), and demonstrate real tools used to automate short-lived certificate issuance and deployment.

## 📌 Use Cases Covered

1. **Venafi Cloud** with `vcert` and `VenafiPS`
2. **EJBCA / Keyfactor** with REST API (Python)
3. **ACME** automation with `certbot`
4. **cert-manager** in Kubernetes clusters

Each folder is a standalone working example with:
- Installation/setup instructions
- Scripts or manifests
- Test deployment to verify cert install

## 🛠 Requirements
### Prerequisites
- Any Linux host (wsl, VM etc.) to run and host the kubernetes cluster and any non powershell script.
- Docker installed
- (Optional) VSCode via `Remote - WSL extension`

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

| Folder               | Description                                    |
|----------------------|------------------------------------------------|
| `venafi-cloud-api`   | Automate TLS cert requests with Venafi Cloud  |
| `cert-manager-k8s`   | Kubernetes-native TLS automation with cert-manager |
| `ejbca-rest-python`  | Use EJBCA REST API for issuance                |
| `acme-certbot`       | Script cert issuance with certbot             |
