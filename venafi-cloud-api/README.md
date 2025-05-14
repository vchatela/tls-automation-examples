# 🔐 Venafi Cloud Integration Examples

This folder contains examples of how to automate TLS certificate issuance using **Venafi Cloud**, aligned with modern best practices like short-lived certificates and Kubernetes integration.

We use the built-in `Default` CA provided in the 30-day Venafi Cloud trial.

---

## 📚 What You'll Find

| Use Case | Tooling      | Folder/Script         | Description                                          |
|----------|--------------|-----------------------|------------------------------------------------------|
| ✅ Using binary | `vcert` (CLI) | `request_cert.sh`       | Bash script to request a certificate from Venafi Cloud |
| 🔄 Using library | PowerShell (`VenafiPS`) | `request_cert.ps1`      | Equivalent cert request in Windows environment       |
| 🚀 Using managed tool | `cert-manager` | `cert-manager/`         | Use cert-manager + Venafi Cloud in Kubernetes        |

In the two first use cases we will focus on getting the certificate, on the third we will then import those results as secrets so to be used by a NGINX Frontend for demo purpose.

---

## 🧩 Prerequisites
### Venafi Cloud
1. Start a new [Venafi Cloud Trial (30 days)](https://www.cyberark.com/try-buy/certificate-manager-saas-trial/)
2. Get your API Key on your [https://eval-xxxxxxxx.venafi.cloud/](https://eval-xxxxxxxx.venafi.cloud/) by clicking on your avatar → **Preferences** → **API Keys**
3. Make this API Key in your env
```bash
export VCERT_APIKEY="YOUR_API_KEY_HERE"
# echo 'export VCERT_APIKEY="YOUR_API_KEY_HERE"' >> ~/.bashrc
```
```powershell
$env:VCERT_APIKEY = "YOUR_API_KEY_HERE"
```
1. Create an application in the portal, go to **Applications** → **Add Application**:
   * A name like `tls-demo-venafi-1`
   * Yourself as the owner
   * The `Default` template
2. (Optionnal) If you want Venafi to be able to generate private keys, you need to setup a [vSatellite](https://docs.venafi.cloud/vsatellite/t-VSatellite-deployNew/) which will encrypt (using local KEK) VaaS sensitive data. 
```bash
$ sudo ./vsatctl preflight --api-url https://api.eu.venafi.cloud/
$ sudo ./vsatctl install --pairing-code xxxxxxx --api-url https://api.eu.venafi.cloud/
INFO Registering with cloud...
INFO Venafi VSatellite registration successful
INFO Using Venafi API URL https://api.eu.venafi.cloud/, location 10.x.x.x
INFO VSatellite installation is currently in progress, for detailed logs please check /root/logs/install.log
INFO VSatellite installation has been completed successfully!
```

---

## Use Case 1: `vcert` enrollment 
This example shows how to leverage CyberArk/Venafi's developped binary `vcert` to operate certificates with low level requirements.
### Prerequisites
To ensure `vcert` is available, run:
```bash
./install-vcert.sh
```
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

## Usecase 2: `VenafiPS` enrollment 
This example shows how to request a certificate using PowerShell with the official VenafiPS module. It's useful when you're on a Windows environment and prefer scripting in PowerShell rather than Bash.
### Prerequisites
VenafiPS must be installed in your powerhsell.

```powershell
Install-Module VenafiPS -Scope CurrentUser -Force
```

### Request a Certificate
```powershell
PS D:\Git\tls-automation-examples\venafi-cloud-api> .\request_cert.ps1
[INFO] Connecting to Venafi Cloud...
[INFO] Requesting certificate for CN: tls-demo-venafi-ps.vchatela.local...

✅ Certificate issued and saved:
- Cert:  D:\Git\tls-automation-examples\venafi-cloud-api\artefacts\venafips-cert.pem
- Chain: D:\Git\tls-automation-examples\venafi-cloud-api\artefacts\venafips-chain.pem
```

## Usecase 3: `cert-manager` enrollment and certificate installation for NGINX
https://cert-manager.io/v1.16-docs/configuration/venafi/

## 🔗 References

* [Venafi Cloud Docs](https://docs.venafi.cloud)
* [vcert GitHub](https://github.com/Venafi/vcert)
* [CyberArk Venafi Cloud Trial](https://www.cyberark.com/try-buy/certificate-manager-saas-trial/)
