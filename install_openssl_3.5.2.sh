#!/bin/bash
set -e

OPENSSL_VERSION="3.5.2"
INSTALL_DIR="$HOME/openssl-$OPENSSL_VERSION-local"

# Download OpenSSL
wget https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz

# Extract
tar xzf openssl-$OPENSSL_VERSION.tar.gz
cd openssl-$OPENSSL_VERSION

# Configure for local install
./Configure --prefix="$INSTALL_DIR" --openssldir="$INSTALL_DIR" '-Wl,-rpath,$(LIBRPATH)'

# Build and install
make -j$(nproc)
make install

echo "OpenSSL $OPENSSL_VERSION installed in $INSTALL_DIR"
echo "To use it, add $INSTALL_DIR/bin to your PATH."
