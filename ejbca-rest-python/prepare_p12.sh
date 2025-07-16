openssl pkcs12 -in valentin-admin.p12 -clcerts -nokeys -out valentin-admin.pem
openssl pkcs12 -in valentin-admin.p12 -nocerts -nodes -out valentin-admin.key
