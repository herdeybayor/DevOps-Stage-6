#!/bin/bash
# Initialize Traefik configuration files

# Create traefik directory if it doesn't exist
mkdir -p traefik/config

# Create acme.json file with proper permissions
touch traefik/acme.json
chmod 600 traefik/acme.json

echo "Traefik initialization complete!"
echo "- Created traefik/acme.json with 600 permissions"
echo "- Created traefik/config directory for middleware configurations"

