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

# Function to detect environment
detect_environment() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

# Function to validate environment file
check_env_file() {
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        print_error ".env file not found!"
        print_status "Copy .env.example to .env and configure your settings:"
        print_status "  cp .env.example .env"
        exit 1
    fi
}

# Function to create data directories
create_data_dirs() {
    local env=$1
    source "$PROJECT_ROOT/.env"
    
    if [[ -n "$HOMELAB_DATA_ROOT" ]]; then
        print_status "Creating data directories in $HOMELAB_DATA_ROOT"
        mkdir -p "$HOMELAB_DATA_ROOT"/{traefik,portainer,prometheus,grafana,config}
        
        # Copy config files if they don't exist in data root
        if [[ "$env" != "mac" ]]; then
            if [[ ! -d "$HOMELAB_DATA_ROOT/config/traefik" ]]; then
                cp -r "$PROJECT_ROOT/config/traefik" "$HOMELAB_DATA_ROOT/config/"
            fi
            if [[ ! -d "$HOMELAB_DATA_ROOT/config/monitoring" ]]; then
                cp -r "$PROJECT_ROOT/config/monitoring" "$HOMELAB_DATA_ROOT/config/"
            fi
        fi
    fi
}

# Main function
main() {
    local env=${1:-$(detect_environment)}
    
    print_status "Starting homelab stack for environment: $env"
    
    # Validate environment
    case $env in
        mac|ubuntu)
            ;;
        *)
            print_error "Unknown environment: $env"
            print_status "Usage: $0 [mac|ubuntu]"
            exit 1
            ;;
    esac
    
    # Check prerequisites
    check_env_file
    
    # Create data directories
    create_data_dirs "$env"
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build compose command
    local compose_files="-f compose/base/docker-compose.base.yml -f compose/env/docker-compose.${env}.yml"
    
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
