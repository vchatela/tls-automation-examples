# 🔐 Venafi Cloud Integration Examples

This folder contains examples of how to automate TLS certificate issuance using **Venafi Cloud**, aligned with modern best practices like short-lived certificates and Kubernetes integration.

We use the built-in `Default` CA provided in the 30-day Venafi Cloud trial.

---

## 📚 What You'll Find

| Use Case | Tooling      | Folder/Script         | Description                                          |
|----------|--------------|-----------------------|------------------------------------------------------|
| ✅ Basic Test | `vcert` (CLI) | `request_cert.sh`       | Bash script to request a certificate from Venafi Cloud |
| 🔄 Coming Soon | PowerShell (`VenafiPS`) | `request_cert.ps1`      | Equivalent cert request in Windows environment       |
| 🚀 Coming Soon | `cert-manager` | `cert-manager/`         | Use cert-manager + Venafi Cloud in Kubernetes        |

In the two first use cases we will focus on getting the certificate, on the third we will then import those results as secrets so to be used by a NGINX Frontend for demo purpose.
---

## 🧩 Prerequisites

- [Venafi Cloud Trial (30 days)](https://www.cyberark.com/try-buy/certificate-manager-saas-trial/)
- Bash shell (Linux/macOS/WSL)
- Tools: `curl`, `unzip`, `sudo`
- (Optional) Kubernetes cluster (for later steps)


---

## Venafi Cloud Setup

### 🔑 Get Your API Key

1. Log in to [https://eval-xxxxxxxx.venafi.cloud/](https://eval-xxxxxxxx.venafi.cloud/)
2. Click your avatar → **Preferences** → **API Keys**
3. Generate and copy a key
4. Export it in your shell:

```bash
export VCERT_APIKEY="YOUR_API_KEY_HERE"
````

To persist it:

```bash
echo 'export VCERT_APIKEY="YOUR_API_KEY_HERE"' >> ~/.bashrc
```

### 🏗️ Create an Application

1. In the portal, go to **Applications**
2. Click **Add Application**
3. Choose:
   * A name like `tls-demo-venafi-1`
   * Yourself as the owner
   * The `Default` template

---

## Use Case 1: `vcert` enrollment 
### Getting vcert
To ensure `vcert` is available, run:

```bash
./install-vcert.sh
```

This will:
* Check if `vcert` is already installed
* If not, download and install version `5.9.0` from GitHub

---

### Request a Certificate

Run:

```bash
> ./request_cert.sh
Enter key passphrase:***
Verifying - Enter key passphrase:***
vCert: 2025/05/13 17:06:13  Warning: command line parameter -k has overridden environment variable VCERT_APIKEY 
vCert: 2025/05/13 17:06:13 Successfully connected to Venafi as a Service
vCert: 2025/05/13 17:06:13 Successfully read zone configuration for tls-demo-venafi-1\Default
vCert: 2025/05/13 17:06:13 Successfully created request for tls-demo-venafi-vcert.vchatela.local
vCert: 2025/05/13 17:06:16 Successfully posted request for tls-demo-venafi-vcert.vchatela.local, will pick up by cf7489a0-300b-11f0-aac3-b5b2a373686d
vCert: 2025/05/13 17:06:16 Successfully retrieved request for cf7489a0-300b-11f0-aac3-b5b2a373686d
PickupID="cf7489a0-300b-11f0-aac3-b5b2a373686d"
Certificate issued and saved:
- Cert: artefacts/vcert-cert.pem
- Key: artefacts/vcert-key.pem
- Chain: artefacts/vcert-chain.pem
```

This script will:

* Authenticate to Venafi Cloud
* Use the `Default` CA zone
* Request a cert for a configured CN (edit the script to change it)
* Save the result in the `artefacts/` folder

> 🔧 Edit the CN in `request_cert.sh` to match your desired FQDN.

## Usecase 2: `VenafiPS` enrollment 


## Usecase 3: `cert-manager` enrollment and certificate installation for NGINX

## 🔗 References

* [Venafi Cloud Docs](https://docs.venafi.cloud)
* [vcert GitHub](https://github.com/Venafi/vcert)
* [CyberArk Venafi Cloud Trial](https://www.cyberark.com/try-buy/certificate-manager-saas-trial/)
