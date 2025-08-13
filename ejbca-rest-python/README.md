
# EJBCA REST API Certificate Automation: Standard & PQC

This example demonstrates how to use **EJBCA Community Edition** to automate TLS certificate issuance via its **REST API** for both classic (RSA/ECC) and post-quantum (ML-DSA-65) certificates. You will:

- Generate a standard RSA certificate via REST API
- Generate a PQC (ML-DSA-65) certificate via REST API

The setup includes role-based access control and certificate generation using `valentin-admin`.

---

## 📁 Contents

| Use Case                  | Tooling        | Files                                                                                                      | Description                                            |
| ------------------------- | -------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| ✅ Prepare EJBCA RA access | `ejbca.sh` CLI | `prepare_ejbca.sh`, `profiles/`                                                                            | Sets up profiles, roles, and the admin user            |
| ✅ Manual RA portal login  | Web UI         | [https://localhost/ejbca/ra/enrollwithusername.xhtml](https://localhost/ejbca/ra/enrollwithusername.xhtml) | Used to download `valentin-admin.p12` bundle           |
| ✅ Generate Admin credentials  | `openssl`      | `prepare_p12.sh`                                                                                           | Converts `p12` into `.pem` and `.key`                  |
| ✅ Enroll via REST API     | Python         | `pkcs10Enroll.py`, `server-01.conf`, `generate_csr.sh`                                                     | Generates CSR and sends request to EJBCA REST endpoint |

---

## 🧌 Prerequisites

* Docker and Docker Compose installed
* Python 3 with `requests` module
* `openssl` CLI

---

## 🚀 Step 0 – Start EJBCA

```bash
docker compose up
```

> ⏰ To restart after stopping:

```bash
# Stop with CTRL+C
# Then restart:
docker compose up
```

---

## 🛠️ Step 1 – Prepare EJBCA

Run the preparation script:

```bash
./prepare_ejbca.sh
```

This will:

* Export `ManagementCA.pem`
* Import Certificate and End Entity Profiles from `./profiles/`
* Create `TLS_API_ROLE` with RA permissions
* Create `valentin-admin` with a P12 token

Then visit:

```url
https://localhost/ejbca/ra/enrollwithusername.xhtml
```

Login with:

* Username: `valentin-admin`
* Password: `FooBar123`

Download the `.p12` bundle.

---

## 🔐 Step 2 – Extract `.p12` to `.pem` and `.key`

```bash
./prepare_p12.sh
```

You will get:

* `valentin-admin.key`
* `valentin-admin.pem`

---

## 🔁 Step 3 – Restart EJBCA for REST API

To ensure the REST interface is ready:

```bash
docker compose down
docker compose up
```

---

## 🖋️ Step 4 – Generate CSR

```bash
./generate_csr.sh
```

This generates:

* `server-01.key`
* `server-01.csr`
* `server-02-pqc.key`
* `server-02-pqc.csr`

---


## 🧪 Step 5 – Test 1: Standard Certificate via REST API

Request a classic RSA certificate:

```bash
python3 pkcs10Enroll.py \
  -c server-01.csr \
  -H localhost \
  -u server-01 \
  -p CP_TLS_Server_30d \
  -e EEP_TLS_Server \
  -t ManagementCA.pem \
  -k valentin-admin.key \
  -C valentin-admin.pem \
  -n ManagementCA
```

You will receive a JSON response with a base64-encoded DER certificate. To decode and inspect:

```bash
echo "<base64 cert>" | base64 -d > server-01.der
openssl x509 -inform der -in server-01.der -out server-01.crt
openssl x509 -in server-01.crt -noout -text
```

## 🧪 Step 6 – Test 2: PQC Certificate via REST API

Request a PQC (ML-DSA-65) certificate:

```bash
python3 pkcs10Enroll.py \
  -c server-02-pqc.csr \
  -H localhost \
  -u server-02-pqc \
  -p CP_TLS_Server_30d_PQC \
  -e EEP_TLS_Server \
  -t ManagementCA.pem \
  -k valentin-admin.key \
  -C valentin-admin.pem \
  -n ManagementCA
```

You will receive a JSON response with a base64-encoded DER certificate. To decode and inspect:

```bash
echo "<base64 cert>" | base64 -d > server-02-pqc.der
$HOME/openssl-3.5.2-local/bin/openssl x509 -inform der -in server-02-pqc.der -out server-02-pqc.crt
$HOME/openssl-3.5.2-local/bin/openssl x509 -in server-02-pqc.crt -noout -text
```

You should see output like:
```
        Subject Public Key Info:
            Public Key Algorithm: ML-DSA-65
                ML-DSA-65 Public-Key:
```

---



---


## 📆 Output Summary

| File                   | Description                         |
| ---------------------- | ----------------------------------- |
| `server-01.key`        | TLS private key (classic)           |
| `server-01.csr`        | Certificate signing request (classic)|
| `server-01.crt`        | Signed certificate (PEM, classic)   |
| `server-02-pqc.key`    | PQC (ML-DSA-65) private key         |
| `server-02-pqc.csr`    | PQC certificate signing request     |
| `server-02-pqc.crt`    | PQC signed certificate (PEM format) |
| `valentin-admin.key`   | RA admin private key                |
| `valentin-admin.pem`   | RA admin certificate                |
| `ManagementCA.pem`     | Root CA certificate                 |

---

## 🔗 References

* [EJBCA Community Docs](https://doc.primekey.com/ejbca)
* [REST API Guide](https://docs.keyfactor.com/ejbca/latest/ejbca-rest-interface)