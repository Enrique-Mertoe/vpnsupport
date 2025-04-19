# OpenVPN Client Provisioning System

A comprehensive system for managing OpenVPN client provisioning and Mikrotik hotspot functionality, developed by Abutimartin with collaboration from Alpha.

## Features

- OpenVPN client certificate generation
- Mikrotik hotspot integration
- Asynchronous task processing with Celery
- Monitoring and metrics with Prometheus and Grafana
- Domain management with automatic SSL
- Docker-based deployment
- Comprehensive management scripts

## Prerequisites

### OpenVPN Server Setup
Before installing this system, you need a working OpenVPN server. The recommended way to set up OpenVPN is:

```bash
# Download and run the official OpenVPN installer
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
```

This script will:
- Install OpenVPN
- Set up the server configuration
- Generate necessary certificates
- Configure the firewall
- Set up the service

### Other Prerequisites
- Docker and Docker Compose
- Python 3.x
- Virtualenv
- Nginx (for domain management)
- Certbot (for SSL certificates)

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd vpnsupport
```

2. Make the installation script executable:
```bash
chmod +x install.sh
```

3. Run the installation script:
```bash
./install.sh
```

The installation script will:
- Verify OpenVPN server setup
- Set up a Python virtual environment
- Install required dependencies
- Create necessary directories
- Build and start Docker containers
- Optionally configure domain and SSL

## Management Scripts

### Installation
```bash
./install.sh
```
Handles initial setup and installation of all components.

### Monitoring
```bash
./monitor.sh
```
Provides real-time monitoring of services, containers, and system resources.

### Certificate Management
```bash
./cert_manage.sh
```
Manages OpenVPN client certificates, including:
- Listing clients
- Viewing certificate details
- Revoking certificates
- Creating backups

### Domain Management
```bash
./domain_manager.sh
```
Manages domain configuration and SSL certificates:
- Add new domains
- Remove existing domains
- List configured domains
- Renew SSL certificates

## Service Access

After installation, services are available at:

- Web Interface: `http://localhost:5000` or `https://your-domain.com`
- Flower (Celery Monitor): `http://localhost:5555` or `https://your-domain.com/flower`
- Grafana: `http://localhost:3000` or `https://your-domain.com/grafana`
- Prometheus: `http://localhost:9090` or `https://your-domain.com/prometheus`

## Directory Structure

```
vpnsupport/
├── app/                    # Flask application code
├── dev_certs/             # OpenVPN certificates
├── prometheus/            # Prometheus configuration
├── scripts/               # Management scripts
│   ├── install.sh
│   ├── monitor.sh
│   ├── cert_manage.sh
│   └── domain_manager.sh
├── Dockerfile            # Web application container
├── Dockerfile.celery     # Celery worker container
├── docker-compose.yml    # Service orchestration
├── requirements.txt      # Python dependencies
└── .env                  # Environment variables
```

## Environment Configuration

The system uses a `.env` file for configuration. A template is provided in `.env.production`. During installation, you'll be prompted to configure this file.

## Maintenance

### Regular Tasks
- Monitor system health with `./monitor.sh`
- Renew SSL certificates with `./domain_manager.sh` (option 4)
- Backup certificates with `./cert_manage.sh`

### Troubleshooting
- Check service status: `docker-compose ps`
- View logs: `docker-compose logs [service_name]`
- Restart services: `docker-compose restart`

## Security Considerations

- Keep SSL certificates up to date
- Regularly backup certificates
- Monitor system access logs
- Use strong passwords for all services
- Keep system and dependencies updated

## Support

For issues and feature requests, please contact:
- Abutimartin (Main Developer)
- Alpha (Collaborator)

## License

[Add your license information here]

## Acknowledgments

- OpenVPN project
- Mikrotik
- Docker community
- Let's Encrypt
- Prometheus and Grafana teams 