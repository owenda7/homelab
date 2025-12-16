# Ubuntu/Linux Production Setup

## Prerequisites

1. **Docker and Docker Compose** installed:
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   
   # Install Docker Compose
   sudo apt update
   sudo apt install docker-compose-plugin
   ```

2. **System preparation**:
   ```bash
   # Create homelab directory
   sudo mkdir -p /srv/homelab
   sudo chown $USER:$USER /srv/homelab
   
   # Clone repository
   cd /srv/homelab
   git clone <your-repo-url> .
   ```

## Configuration

1. **Environment setup**:
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   Key settings for Ubuntu:
   ```bash
   HOMELAB_DOMAIN=yourdomain.com  # or homelab.local for local-only
   HOMELAB_DATA_ROOT=/srv/homelab
   HOMELAB_EMAIL=your@email.com
   TZ=America/New_York
   ```

2. **Directory permissions**:
   ```bash
   # Create data directories
   mkdir -p /srv/homelab/{traefik,portainer,prometheus,grafana}
   
   # Set proper ownership for service users
   sudo chown -R 472:472 /srv/homelab/grafana      # grafana user
   sudo chown -R 65534:65534 /srv/homelab/prometheus  # nobody user
   ```

## Systemd Service (Optional)

To start homelab automatically on boot:

1. **Copy service file**:
   ```bash
   sudo cp host/ubuntu/systemd-units/docker-compose-homelab.service /etc/systemd/system/
   ```

2. **Enable and start**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable docker-compose-homelab.service
   sudo systemctl start docker-compose-homelab.service
   ```

3. **Check status**:
   ```bash
   sudo systemctl status docker-compose-homelab.service
   ```

## Network Configuration

### Local Access Only
- Use `homelab.local` domain
- Add entries to `/etc/hosts` on client machines:
  ```
  <server-ip> traefik.homelab.local
  <server-ip> portainer.homelab.local
  <server-ip> grafana.homelab.local
  ```

### External Access
- Configure DNS A records pointing to your server
- Ensure ports 80/443 are forwarded from router
- Consider using Cloudflare for DNS and SSL

## Security Considerations

1. **Firewall setup**:
   ```bash
   sudo ufw allow ssh
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **SSL certificates**:
   - Let's Encrypt configured automatically via Traefik
   - Certificates stored in `/srv/homelab/traefik/acme.json`

3. **Access control**:
   - Services protected by Traefik middlewares
   - Consider VPN for admin access
   - Regular security updates via Watchtower

## Monitoring

- **System metrics**: Consider adding node-exporter
- **Container metrics**: cAdvisor integration available
- **Log aggregation**: Centralized logging with Loki (optional)

## Backup Strategy

```bash
# Backup script example
#!/bin/bash
BACKUP_DIR="/backup/homelab-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup volumes
docker run --rm -v traefik-data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/traefik.tar.gz -C /data .
docker run --rm -v grafana-data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/grafana.tar.gz -C /data .
docker run --rm -v prometheus-data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/prometheus.tar.gz -C /data .

# Backup configs
cp -r /srv/homelab/config "$BACKUP_DIR/"
cp /srv/homelab/.env "$BACKUP_DIR/"
```

## Troubleshooting

### Common Issues

1. **Permission denied**: Check directory ownership and Docker group membership
2. **Port conflicts**: Ensure no other services using ports 80/443/8080
3. **DNS issues**: Verify domain configuration and DNS propagation
4. **SSL issues**: Check Let's Encrypt rate limits and domain validation

### Useful Commands

```bash
# View all containers
docker ps -a

# Check service logs
./scripts/logs.sh [service]

# Restart specific service
docker compose -f compose/base/docker-compose.base.yml -f compose/env/docker-compose.ubuntu.yml restart [service]

# Update all containers
docker compose pull && ./scripts/up.sh ubuntu
```
