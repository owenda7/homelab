# macOS Docker Desktop Configuration

## Prerequisites

1. **Docker Desktop for Mac** installed and running
2. **Resource allocation** configured appropriately:
   - Memory: 8GB+ recommended for full stack
   - CPU: 4+ cores recommended
   - Disk: 100GB+ for container images and data

## File Sharing

Docker Desktop automatically shares `/Users`, `/Volumes`, `/private`, and `/tmp`. The homelab configuration uses:
- Config files: Mounted from repository (read-only)
- Data storage: Uses Docker named volumes for better performance

## Performance Considerations

### Volume Performance
- Named volumes perform better than bind mounts on macOS
- The configuration uses named volumes for database storage
- Config files are bind-mounted (read-only) for easy editing

### Resource Limits
- Each service has memory limits configured in `docker-compose.mac.yml`
- Adjust limits based on your Mac's available resources
- Monitor usage via Docker Desktop dashboard

## Network Configuration

- Services use the `homelab` bridge network
- Access services via `http://service.homelab.local`
- Add to `/etc/hosts` if needed:
  ```
  127.0.0.1 traefik.homelab.local
  127.0.0.1 portainer.homelab.local
  127.0.0.1 grafana.homelab.local
  127.0.0.1 prometheus.homelab.local
  ```

## Data Persistence

Data is stored in Docker named volumes:
- `traefik-data`: SSL certificates and Traefik data
- `portainer-data`: Portainer configuration
- `prometheus-data`: Metrics data
- `grafana-data`: Dashboards and settings

To backup data:
```bash
docker run --rm -v traefik-data:/data -v $(pwd):/backup alpine tar czf /backup/traefik-backup.tar.gz -C /data .
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 443, 8080 are available
2. **Memory issues**: Increase Docker Desktop memory allocation
3. **File permissions**: Docker Desktop handles permissions automatically
4. **DNS resolution**: Use `host.docker.internal` to access host services

### Useful Commands

```bash
# Check Docker Desktop status
docker system info

# View resource usage
docker stats

# Clean up unused resources
docker system prune -a

# Reset Docker Desktop (nuclear option)
# Docker Desktop > Troubleshoot > Reset to factory defaults
```

## Development Workflow

1. Edit configuration files in the repository
2. Restart affected services: `./scripts/up.sh mac`
3. View logs: `./scripts/logs.sh [service]`
4. Access services via browser using `.homelab.local` domains
