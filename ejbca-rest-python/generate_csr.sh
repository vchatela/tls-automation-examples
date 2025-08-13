# # Generate private key
openssl genpkey -algorithm RSA -out server-01.key -pkeyopt rsa_keygen_bits:3072

# # Generate CSR using the config
openssl req -new -key server-01.key -out server-01.csr -config server-01.conf

# Generate ML-DSA-65 private key
/home/valentinc/openssl-3.5.2-local/bin/openssl genpkey -algorithm ML-DSA-65 -out server-02-pqc.key

# Generate CSR using the ML-DSA-65 key
/home/valentinc/openssl-3.5.2-local/bin/openssl req -new -key server-02-pqc.key -out server-02-pqc.csr -config server-02.conf