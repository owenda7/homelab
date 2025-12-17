#!/bin/bash

# Homelab Docker Compose startup script
# Automatically detects environment or accepts explicit argument

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ensure cursor is normal on exit
trap "tput cnorm" EXIT

# hide cursor temporarily
tput civis

# Function to install Docker
install_docker() {

    if command -v docker >/dev/null 2>&1; then
        print_status "Docker already installed...skipping"
    else
        print_status "Installing Docker..."
        curl -fsSL https://get.docker.com | sh > /dev/null
    	sudo newgrp docker
    	sudo usermod -aG docker $(whoami)
    fi
}

# Function to validate environment file
check_env_file() {
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        print_error ".env file not found!"
        exit 1
    fi
}

# Function to create data directories
create_data_dirs() {
    source "$PROJECT_ROOT/.env"
    
    if [[ -n "$HOMELAB_DATA_ROOT" ]]; then
        print_status "Creating data directories in $HOMELAB_DATA_ROOT"
        mkdir -p "$HOMELAB_DATA_ROOT"/{traefik,portainer,prometheus,grafana,config}
    else
	print_error "HOMELAB_DATA_ROOT not set in .env"
	exit 1
    fi
}

# Main function
main() {
    
    print_status "Starting homelab stack for environment: $env"

    # Docker install
    install_docker
    
    # Check prerequisites
    check_env_file
    
    # Create data directories
    create_data_dirs
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build compose command
    local compose_files="-f docker-compose.yml"
    
    print_status "Running: docker compose $compose_files up -d"
    
    # Start services
    if docker compose $compose_files up -d; then
        print_status "Homelab stack started successfully!"
        print_status ""
        print_status "Services available at:"
        print_status "  Traefik Dashboard: http://traefik.${HOMELAB_DOMAIN}"
        print_status "  Portainer:         http://portainer.${HOMELAB_DOMAIN}"
        print_status "  Nextcloud:         http://nextcloud.${HOMELAB_DOMAIN}"
        print_status ""
        print_status "View logs with: ./scripts/logs.sh"
        print_status "Stop services with: ./scripts/down.sh"
    else
        print_error "Failed to start homelab stack!"
        exit 1
    fi
}

# Run main function
main "$@"
