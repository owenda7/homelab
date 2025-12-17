# Homelab Docker Configuration

A portable Docker Compose setup for homelab services, designed to work across Ubuntu (production) and macOS (development/testing).

## Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your settings:**
   - Set `HOMELAB_DOMAIN` (e.g., `homelab.local`)
   - Set `HOMELAB_DATA_ROOT` (e.g., `/srv/homelab` on Ubuntu, `/Users/you/homelab-data` on macOS)
   - Configure other variables as needed

3. **Start the stack:**
   ```bash
   # Auto-detect environment
   ./scripts/up.sh
   
   # Or specify explicitly
   ./scripts/up.sh mac
   ./scripts/up.sh ubuntu
   ```

4. **Access services:**
   - Traefik Dashboard: `http://traefik.${HOMELAB_DOMAIN}`
   - Portainer: `http://portainer.${HOMELAB_DOMAIN}` - Container management UI
   - **Nextcloud: `http://nextcloud.${HOMELAB_DOMAIN}` - Personal cloud storage**

## Nextcloud - Personal Cloud Storage

Nextcloud is your primary file storage and collaboration platform, providing:

- **File Storage & Sync**: Access files from any device with automatic synchronization
- **Mobile Apps**: iOS and Android apps for seamless mobile access
- **Desktop Sync**: Desktop clients for Windows, macOS, and Linux
- **Web Interface**: Full-featured web UI for file management
- **File Sharing**: Share files and folders with links or specific users
- **Collaboration**: Real-time document editing and commenting
- **Calendar & Contacts**: Built-in calendar and contact management
- **Photo Management**: Automatic photo backup and organization
- **Security**: End-to-end encryption and secure file sharing
- **Apps Ecosystem**: Extend functionality with hundreds of apps

### Initial Setup
1. Access Nextcloud at `http://nextcloud.${HOMELAB_DOMAIN}`
2. Login with admin credentials from your `.env` file
3. Install mobile/desktop apps from [nextcloud.com/install](https://nextcloud.com/install)
4. Configure automatic photo backup and file sync

### Client Apps
- **Desktop**: Windows, macOS, Linux sync clients
- **Mobile**: iOS and Android apps with auto-upload
- **WebDAV**: Direct file access via WebDAV protocol

## Portainer - Container Management

Portainer provides a comprehensive web UI for Docker management:

- **Container Management**: View, start, stop, restart, and inspect all containers
- **Image Management**: Pull, build, and manage Docker images
- **Volume Management**: Create and manage Docker volumes and bind mounts
- **Network Management**: Configure and monitor Docker networks
- **Stack Management**: Deploy and manage Docker Compose stacks
- **Resource Monitoring**: Real-time CPU, memory, and network usage
- **Log Viewing**: Access container logs through the web interface
- **User Management**: Role-based access control for team environments

Access Portainer at `http://portainer.${HOMELAB_DOMAIN}` after starting the stack.

## Architecture

### Core Services
- **Traefik**: Reverse proxy with automatic SSL
- **Nextcloud**: Personal cloud storage and file synchronization
- **Portainer**: Docker management UI
- **Watchtower**: Automatic container updates

### Directory Structure
```
compose/
  base/           # Core service definitions
  env/            # Environment-specific overrides
config/           # Service configurations (git-tracked)
secrets/          # Local secrets (git-ignored)
scripts/          # Helper scripts
host/             # Host-specific docs and configs
```

## Environment Support

### Ubuntu (Production)
- Data stored in `/srv/homelab/`
- Systemd service for auto-start
- Host networking for some services

### macOS (Development)
- Data stored in `~/homelab-data/`
- Docker Desktop integration
- Resource limits configured

## Management Commands

```bash
# Start services
./scripts/up.sh [env]

# Stop services
./scripts/down.sh

# View logs
./scripts/logs.sh [service]

# Update containers
docker compose pull && ./scripts/up.sh
```

## Adding New Services

1. Add service definition to appropriate file in `compose/base/`
2. Add any configs to `config/[service]/`
3. Update environment overrides in `compose/env/` if needed
4. Update this README

## Security Notes

- All secrets go in `secrets/` directory (git-ignored)
- Use strong passwords and API keys
- Consider VPN access for external exposure
- Regular updates via Watchtower or manual pulls
