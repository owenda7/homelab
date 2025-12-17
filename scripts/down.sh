#!/bin/bash

# Homelab Docker Compose shutdown script

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

# Main function
main() {
    local env=${1:-$(detect_environment)}
    local remove_volumes=${2:-false}
    
    print_status "Stopping homelab stack for environment: $env"
    
    # Validate environment
    case $env in
        mac|ubuntu)
            ;;
        *)
            print_error "Unknown environment: $env"
            print_status "Usage: $0 [mac|ubuntu] [--remove-volumes]"
            exit 1
            ;;
    esac
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build compose command
    local compose_files="-f compose/base/docker-compose.base.yml -f compose/env/docker-compose.${env}.yml"
    
    if [[ "$remove_volumes" == "--remove-volumes" ]]; then
        print_warning "Removing containers AND volumes (data will be lost!)"
        print_status "Running: docker compose $compose_files down -v"
        docker compose $compose_files down -v
    else
        print_status "Running: docker compose $compose_files down"
        docker compose $compose_files down
    fi
    
    print_status "Homelab stack stopped successfully!"
    print_status ""
    print_status "To start again: ./scripts/up.sh $env"
    if [[ "$remove_volumes" != "--remove-volumes" ]]; then
        print_status "To remove volumes: ./scripts/down.sh $env --remove-volumes"
    fi
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [environment] [--remove-volumes]"
    echo ""
    echo "Arguments:"
    echo "  environment      Target environment (mac|ubuntu). Auto-detected if not specified."
    echo "  --remove-volumes Remove Docker volumes (WARNING: This will delete all data!)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Stop services, auto-detect environment"
    echo "  $0 mac                # Stop services for macOS"
    echo "  $0 ubuntu --remove-volumes  # Stop and remove all data"
    exit 0
fi

# Run main function
main "$@"
