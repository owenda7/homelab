# WSL2 Setup Notes

## Prerequisites

1. **WSL2 with Ubuntu** installed and configured
2. **Docker Desktop for Windows** with WSL2 backend enabled
3. **Git** installed in WSL2 environment

## WSL2-Specific Considerations

### File System Performance
- Store homelab files in WSL2 filesystem (`/home/user/`) for better performance
- Avoid Windows filesystem (`/mnt/c/`) for Docker volumes
- Use WSL2 native paths in `.env` configuration

### Network Configuration
- WSL2 uses NAT networking by default
- Services accessible from Windows host via `localhost`
- May need DNS configuration for external resolution

### Time Synchronization
- WSL2 can have time drift issues after Windows sleep/hibernate
- Watchtower configured with more frequent polling to handle this
- Manual sync if needed: `sudo hwclock -s`

## Setup Instructions

1. **Clone repository in WSL2**:
   ```bash
   cd ~
   git clone <your-repo-url> homelab
   cd homelab
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   WSL2-specific settings:
   ```bash
   HOMELAB_DOMAIN=homelab.local
   HOMELAB_DATA_ROOT=/home/$USER/homelab-data
   TZ=America/New_York
   ```

3. **Create data directories**:
   ```bash
   mkdir -p ~/homelab-data/{traefik,portainer,nextcloud,pihole,config}
   ```

4. **Start services**:
   ```bash
   ./scripts/up.sh wsl2
   ```

## Docker Desktop Integration

### Settings to Verify
- **WSL2 backend enabled**: Settings > General > Use WSL2 based engine
- **WSL2 distro integration**: Settings > Resources > WSL Integration
- **File sharing**: Automatic with WSL2 backend

### Resource Allocation
- Configure in Docker Desktop: Settings > Resources > WSL Integration
- Memory: 6GB+ recommended for full stack
- Consider Windows host memory when allocating

## Network Access

### From Windows Host
Services accessible via:
- `http://localhost` (with port forwarding)
- `http://traefik.homelab.local` (add to Windows hosts file)

### Windows Hosts File
Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 traefik.homelab.local
127.0.0.1 portainer.homelab.local
127.0.0.1 nextcloud.homelab.local
127.0.0.1 pihole.homelab.local
```

### From WSL2
Services accessible via container names or `localhost`

## Storage Considerations

### Data Persistence
- Use WSL2 filesystem for Docker volumes
- Backup important data regularly
- WSL2 distributions can be exported/imported

### Backup Strategy
```bash
# Export WSL2 distribution (from Windows PowerShell)
wsl --export Ubuntu C:\backup\ubuntu-homelab.tar

# Backup specific volumes (from WSL2)
docker run --rm -v traefik-data:/data -v ~/backup:/backup alpine tar czf /backup/traefik.tar.gz -C /data .
```

## Performance Optimization

### File System
- Keep all homelab files in WSL2 filesystem
- Use named volumes for database storage
- Avoid cross-filesystem operations

### Memory Management
- Monitor WSL2 memory usage: `free -h`
- Configure `.wslconfig` in Windows user directory if needed:
  ```ini
  [wsl2]
  memory=8GB
  processors=4
  ```

## Troubleshooting

### Common Issues

1. **Time sync problems**:
   ```bash
   sudo hwclock -s
   # Or restart WSL2 from Windows PowerShell: wsl --shutdown
   ```

2. **DNS resolution issues**:
   ```bash
   # Check /etc/resolv.conf
   cat /etc/resolv.conf
   # May need to configure custom DNS in Docker Compose
   ```

3. **Port binding issues**:
   ```bash
   # Check if ports are available
   netstat -tulpn | grep :80
   # Windows may reserve ports - check with: netsh int ipv4 show excludedportrange protocol=tcp
   ```

4. **Docker daemon issues**:
   ```bash
   # Restart Docker Desktop from Windows
   # Or check WSL2 integration settings
   ```

### Performance Issues
- Move files from `/mnt/c/` to WSL2 filesystem
- Increase Docker Desktop memory allocation
- Consider using Windows Terminal for better performance

### Useful Commands

```bash
# Check WSL2 status (from Windows PowerShell)
wsl --status
wsl --list --verbose

# Restart WSL2 (from Windows PowerShell)
wsl --shutdown

# Check Docker context (from WSL2)
docker context ls

# Monitor resource usage
htop
docker stats
```

## Development Workflow

1. Edit files in WSL2 using VS Code with WSL extension
2. Test changes: `./scripts/up.sh wsl2`
3. View logs: `./scripts/logs.sh [service]`
4. Access services from Windows browser using localhost or .local domains
