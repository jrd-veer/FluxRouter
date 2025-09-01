#!/bin/bash
# Generate self-signed SSL certificate for FluxRouter

set -e

SSL_DIR="/etc/nginx/ssl"
CERT_FILE="$SSL_DIR/server.crt"
KEY_FILE="$SSL_DIR/server.key"

# Create SSL directory
mkdir -p "$SSL_DIR"

# Generate private key
openssl genrsa -out "$KEY_FILE" 2048

# Generate self-signed certificate (valid for 365 days)
openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 -subj "/C=US/ST=State/L=City/O=FluxRouter/OU=DevOps/CN=localhost"

# Set proper permissions
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ SSL certificate generated successfully!"
echo "Certificate: $CERT_FILE"
echo "Private Key: $KEY_FILE"
