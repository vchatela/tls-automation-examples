# Generate private key
openssl genpkey -algorithm RSA -out server-01.key -pkeyopt rsa_keygen_bits:3072

# Generate CSR using the config
openssl req -new -key server-01.key -out server-01.csr -config server-01.conf
