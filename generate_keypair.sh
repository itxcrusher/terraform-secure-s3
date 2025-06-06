#!/usr/bin/env bash
# -------------------------------------------------------------------
# generate_keypair.sh
#
# Generates a CloudFront RSA key pair (2048 bits) and stores them under
# terraform/keys/. The public key will be used by Terraform to import
# into CloudFront. The private key must be kept secret (not committed).
#
# Usage:
#   ./generate_keypair.sh
#
# Prerequisites:
#   - openssl must be installed and on your PATH.
# -------------------------------------------------------------------

set -e

# Directory where keys will be stored:
KEY_DIR="terraform/keys"
PRIVATE_KEY="${KEY_DIR}/private_key.pem"
PUBLIC_KEY="${KEY_DIR}/public_key.pem"

echo "▶️ Creating key directory at ${KEY_DIR} (if not exists)…"
mkdir -p "${KEY_DIR}"

# 1) Generate a 2048-bit RSA private key
echo "🔑 Generating 2048-bit RSA private key → ${PRIVATE_KEY}…"
openssl genrsa -out "${PRIVATE_KEY}" 2048

# 2) Extract the public key
echo "🗝️  Extracting public key → ${PUBLIC_KEY}…"
openssl rsa -pubout -in "${PRIVATE_KEY}" -out "${PUBLIC_KEY}"

# 3) Secure file permissions
chmod 600 "${PRIVATE_KEY}"
chmod 644 "${PUBLIC_KEY}"

echo "✅ Key pair created!"
echo "   • Private key: ${PRIVATE_KEY}"
echo "   • Public key:  ${PUBLIC_KEY}"
echo ""
echo "ℹ️  IMPORTANT: Keep private_key.pem secure and DO NOT commit it to Git."
