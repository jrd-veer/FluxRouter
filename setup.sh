#!/bin/bash

# FluxRouter Setup Script
# This script automates the initial setup of the .env file.

set -e

ENV_FILE=".env"
EXAMPLE_FILE="env.example"
SECRET_KEY_PLACEHOLDER="your-secret-key-change-in-production-use-random-string"

# --- Helper Functions ---
info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
    exit 1
}

# --- Main Script ---

# 1. Check if .env file already exists
if [ -f "$ENV_FILE" ]; then
    info ".env file already exists. No action taken."
    exit 0
fi

# 2. Check if env.example exists
if [ ! -f "$EXAMPLE_FILE" ]; then
    error "env.example not found. Please ensure the template file is present in the project root."
fi

info "Creating .env file from $EXAMPLE_FILE..."
cp "$EXAMPLE_FILE" "$ENV_FILE"

info "Generating a new secure SECRET_KEY..."
# Generate a 32-byte (256-bit) random key and hex-encode it.
SECRET_KEY=$(openssl rand -hex 32)

# Check if openssl command was successful
if [ -z "$SECRET_KEY" ]; then
    error "Failed to generate secret key. Please ensure 'openssl' is installed and in your PATH."
fi

# 3. Replace the placeholder in the .env file
# Using a temp file and mv for better cross-platform compatibility (works on macOS and Linux)
sed "s/$SECRET_KEY_PLACEHOLDER/$SECRET_KEY/" "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"

info "✅ .env file has been created successfully with a new SECRET_KEY."
echo ""
info "You can now start the platform with: docker compose up -d"
