#!/usr/bin/env bash
set -euo pipefail

# Helper: extract the last JSON object from a file and print its "certificate" value
extract_cert_b64 () {
  local file="$1"
  python3 - "$file" <<'PY'
import sys, json, re, pathlib
p = pathlib.Path(sys.argv[1])
data = p.read_text(errors="ignore")

# Find *all* JSON objects in the file (handles pretty-printed and single-line)
# This regex matches balanced braces conservatively for JSON-like content
objs = [m.group(0) for m in re.finditer(r'\{(?:[^{}]|"(?:\\.|[^"])*")*\}', data, re.S)]
if not objs:
    print("", end="")  # nothing found -> empty string
    sys.exit(0)

last = objs[-1]
try:
    j = json.loads(last)
    print(j.get("certificate",""), end="")
except Exception:
    print("", end="")
PY
}

# Choose OpenSSL (use custom for PQC if present)
OPENSSL_STD="openssl"
OPENSSL_PQC="${HOME}/openssl-3.5.2-local/bin/openssl"
[[ -x "$OPENSSL_PQC" ]] || OPENSSL_PQC="$OPENSSL_STD"

# --- Standard certificate enrollment ---
python3 pkcs10Enroll.py \
  -c server-01.csr \
  -H localhost \
  -u server-01 \
  -p CP_TLS_Server_30d \
  -e EEP_TLS_Server \
  -t ManagementCA.pem \
  -k valentin-admin.key \
  -C valentin-admin.pem \
  -n ManagementCA > server-01.response

CERT_B64="$(extract_cert_b64 server-01.response)"
if [[ -z "${CERT_B64}" ]]; then
  echo "ERROR: Could not extract certificate from server-01.response" >&2
  exit 1
fi

echo "$CERT_B64" | base64 -d > server-01.der
$OPENSSL_STD x509 -inform der -in server-01.der -out server-01.crt
$OPENSSL_STD x509 -in server-01.crt -noout -text

echo -e "\n---\n"

# --- PQC certificate enrollment ---
python3 pkcs10Enroll.py \
  -c server-02-pqc.csr \
  -H localhost \
  -u server-02-pqc \
  -p CP_TLS_Server_30d_PQC \
  -e EEP_TLS_Server \
  -t ManagementCA.pem \
  -k valentin-admin.key \
  -C valentin-admin.pem \
  -n ManagementCA > server-02-pqc.response

PQC_CERT_B64="$(extract_cert_b64 server-02-pqc.response)"
if [[ -z "${PQC_CERT_B64}" ]]; then
  echo "ERROR: Could not extract certificate from server-02-pqc.response" >&2
  exit 1
fi

echo "$PQC_CERT_B64" | base64 -d > server-02-pqc.der
$OPENSSL_PQC x509 -inform der -in server-02-pqc.der -out server-02-pqc.crt
$OPENSSL_PQC x509 -in server-02-pqc.crt -noout -text
