#!/bin/bash

# Local Development Setup Script
# This script sets up the local development environment

set -e

echo "======================================"
echo "DevOps Stage 6 - Local Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Docker is installed
echo "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose is installed"

# Check if .env file exists
echo ""
echo "Setting up environment configuration..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        print_success "Created .env file from .env.example"
        print_warning "Please edit .env file with your actual values!"
    else
        print_error ".env.example file not found"
        exit 1
    fi
else
    print_warning ".env file already exists, skipping creation"
fi

# Initialize Traefik directories
echo ""
echo "Setting up Traefik configuration..."
mkdir -p traefik/config

# Create acme.json with proper permissions
touch traefik/acme.json
chmod 600 traefik/acme.json
print_success "Created traefik/acme.json with proper permissions"

# Create necessary directories
echo ""
echo "Creating necessary directories..."
mkdir -p logs
print_success "Created logs directory"

# Generate JWT secret if not exists
echo ""
echo "Checking JWT secret..."
if grep -q "your-super-secret-jwt-key-change-this" .env; then
    JWT_SECRET=$(openssl rand -base64 32)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|your-super-secret-jwt-key-change-this|${JWT_SECRET}|g" .env
    else
        sed -i "s|your-super-secret-jwt-key-change-this|${JWT_SECRET}|g" .env
    fi
    print_success "Generated and set JWT_SECRET in .env file"
else
    print_warning "JWT_SECRET already configured in .env"
fi

# Pull base images
echo ""
echo "Pulling Docker base images (this may take a few minutes)..."
docker pull node:12-alpine
docker pull golang:1.18-alpine
docker pull maven:3.6-jdk-8
docker pull python:3.8-slim
docker pull nginx:alpine
docker pull redis:7-alpine
docker pull traefik:v2.10
print_success "Docker images pulled successfully"

echo ""
echo "======================================"
echo "Local setup complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your actual values:"
echo "   nano .env"
echo ""
echo "2. Start the services:"
echo "   docker compose up -d"
echo ""
echo "3. Check service status:"
echo "   docker compose ps"
echo ""
echo "4. View logs:"
echo "   docker compose logs -f"
echo ""
echo "5. Access the application:"
echo "   http://localhost"
echo ""
print_success "Ready to start development!"

