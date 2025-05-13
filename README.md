# TLS Automation Examples

This repository contains a collection of practical TLS certificate automation use cases, designed to help organizations transition away from manual certificate management.

These examples accompany a LinkedIn series by [@Valentin](https://www.linkedin.com/in/vchatela), and demonstrate real tools used to automate short-lived certificate issuance and deployment.

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

- Kubernetes cluster (for K8s-related demos)
- PowerShell
- Python 3

## 📂 Folder Overview

| Folder               | Description                                    |
|----------------------|------------------------------------------------|
| `venafi-cloud-api`   | Automate TLS cert requests with Venafi Cloud  |
| `ejbca-rest-python`  | Use EJBCA REST API for issuance                |
| `acme-certbot`       | Script cert issuance with certbot             |
| `cert-manager-k8s`   | Kubernetes-native TLS automation with cert-manager |
