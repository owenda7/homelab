#!/bin/bash

# Homelab Docker Compose logs script

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
    local service="$1"
    local env=${2:-$(detect_environment)}
    local follow=${3:-true}
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build compose command
    local compose_files="-f compose/base/docker-compose.base.yml -f compose/env/docker-compose.${env}.yml"
    
    if [[ -n "$service" ]]; then
        print_status "Showing logs for service: $service"
        if [[ "$follow" == "true" ]]; then
            docker compose $compose_files logs -f "$service"
        else
            docker compose $compose_files logs "$service"
        fi
    else
        print_status "Showing logs for all services"
        if [[ "$follow" == "true" ]]; then
            docker compose $compose_files logs -f
        else
            docker compose $compose_files logs
        fi
    fi
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [service] [environment] [--no-follow]"
    echo ""
    echo "Arguments:"
    echo "  service      Service name to show logs for (optional, shows all if not specified)"
    echo "  environment  Target environment (mac|ubuntu). Auto-detected if not specified."
    echo "  --no-follow  Don't follow logs (show existing logs and exit)"
    echo ""
    echo "Available services:"
    echo "  traefik, portainer, prometheus, grafana, watchtower"
    echo ""
    echo "Examples:"
    echo "  $0                    # Show all logs, follow mode"
    echo "  $0 traefik           # Show traefik logs, follow mode"
    echo "  $0 grafana mac       # Show grafana logs on macOS"
    echo "  $0 prometheus ubuntu --no-follow  # Show prometheus logs without following"
    exit 0
fi

# Parse arguments
service=""
env=""
follow="true"

for arg in "$@"; do
    case $arg in
        --no-follow)
            follow="false"
            ;;
        mac|ubuntu)
            env="$arg"
            ;;
        *)
            if [[ -z "$service" ]]; then
                service="$arg"
            fi
            ;;
    esac
done

# Auto-detect environment if not specified
if [[ -z "$env" ]]; then
    env=$(detect_environment)
fi

# Run main function
main "$service" "$env" "$follow"
