# ACME via Certbot (DNS Challenge)

This example demonstrates how to use [**Certbot**](https://certbot.eff.org/) to request a Let's Encrypt TLS certificate using the **ACME DNS-01 challenge** and serve it over HTTPS with **NGINX**. This setup avoids the need to expose ports 80 or 443 externally by automating DNS validation with Cloudflare.

---

## 📁 Contents

| Use Case                     | Tooling       | Files                 | Description                                              |
|------------------------------|---------------|-----------------------|----------------------------------------------------------|
| ✅ ACME DNS certificate      | `certbot`     | `request-cert.sh`     | Automate Let's Encrypt issuance using Cloudflare plugin |
| ✅ HTTPS test deployment     | `nginx`       | `deploy-nginx.sh`     | Run an NGINX container using the issued cert            |
|                             |               | `default.conf`        | NGINX config with TLS                                    |
|                             |               | `cloudflare.ini`      | API token file (keep secret)                            |

---

## 🧩 Prerequisites

- A **domain** managed by Cloudflare (or supported DNS provider)
- A valid **API token** with permission to edit DNS records
- Linux with `certbot` and `python3-certbot-dns-cloudflare`
- Docker (for the HTTPS demo)

---

## 🔐 Certificate Issuance via DNS-01

### 🔧 1. Prepare Cloudflare Credentials

Create `cloudflare.ini` with:
```ini
dns_cloudflare_api_token = YOUR_CLOUDFLARE_API_TOKEN
````

Make it readable only by your user:

```bash
chmod 600 cloudflare.ini
```

### 📜 2. Run Certbot with DNS Plugin

```bash
./request-cert.sh
```

This script will:

* Request a TLS certificate for `test.xx.xx` via Let's Encrypt
* Solve the DNS challenge via Cloudflare API
* Store the cert in `/etc/letsencrypt/live/test.xx.xx/`

Expected output:

```text
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Requesting a certificate for test.xx.xx
Waiting 10 seconds for DNS changes to propagate

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/test.xx.xx/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/test.xx.xx/privkey.pem
This certificate expires on 2025-08-12.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.
```

---

## 🌐 Serve HTTPS with NGINX

### ▶️ 1. Launch NGINX with Cert Mounted

```bash
./deploy-nginx.sh
```

This will:

* Start NGINX in Docker
* Mount the issued certificate and custom TLS config
* Bind to port 443 on localhost

### 🧪 2. Test the TLS Connection

Use `curl` with a custom DNS resolution:

```bash
curl -vk https://test.xx.xx --resolve test.xx.xx:443:127.0.0.1
```

You should see:

```
* Added test.xx.xx:443:127.0.0.1 to DNS cache
* Hostname test.xx.xx was found in DNS cache
*   Trying 127.0.0.1:443...
* Connected to test.xx.xx (127.0.0.1) port 443
[...]
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / id-ecPublicKey
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: CN=test.xx.xx
*  start date: May 14 08:40:27 2025 GMT
*  expire date: Aug 12 08:40:26 2025 GMT
*  issuer: C=US; O=Let's Encrypt; CN=E6
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
*   Certificate level 0: Public key type EC/prime256v1 (256/128 Bits/secBits), signed using ecdsa-with-SHA384
*   Certificate level 1: Public key type EC/secp384r1 (384/192 Bits/secBits), signed using sha256WithRSAEncryption
* using HTTP/1.x
> GET / HTTP/1.1
> Host: test.xx.xx
> User-Agent: curl/8.5.0
> Accept: */*
>
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
< HTTP/1.1 200 OK
< Server: nginx/1.27.5
< Date: Wed, 14 May 2025 09:47:22 GMT
< Content-Type: application/octet-stream
< Content-Length: 20
< Connection: keep-alive
<
TLS is working 🚀
* Connection #0 to host test.xx.xx left intact
```

---

## 🧼 Cleanup

```bash
docker stop nginx-tls
docker rm nginx-tls
```

---

## 🔗 References

* [Let's Encrypt](https://letsencrypt.org/)
* [Certbot DNS Challenge Docs](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins)
* [Cloudflare API Tokens](https://developers.cloudflare.com/api/tokens/create/)

---