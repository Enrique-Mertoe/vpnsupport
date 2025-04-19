#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to confirm action
confirm() {
    read -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

echo -e "${YELLOW}Starting VPN Service Uninstallation...${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Stop and remove containers
echo -e "${YELLOW}Stopping and removing containers...${NC}"
docker-compose down

# Remove volumes
if confirm "Do you want to remove all Docker volumes? (This will delete all data)"; then
    echo -e "${YELLOW}Removing Docker volumes...${NC}"
    docker volume rm $(docker volume ls -q | grep vpn)
fi

# Remove images
if confirm "Do you want to remove Docker images? (This will delete all application images)"; then
    echo -e "${YELLOW}Removing Docker images...${NC}"
    docker rmi $(docker images | grep vpn | awk '{print $3}')
fi

# Backup certificates before removal
if [ -d "dev_certs" ]; then
    if confirm "Do you want to backup certificates before removal?"; then
        backup_dir="cert_backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Creating backup in $backup_dir...${NC}"
        mkdir -p "$backup_dir"
        cp -r dev_certs/* "$backup_dir/"
        echo -e "${GREEN}Backup completed${NC}"
    fi
fi

# Remove application files
if confirm "Do you want to remove all application files? (This will delete all configurations and certificates)"; then
    echo -e "${YELLOW}Removing application files...${NC}"
    rm -rf dev_certs
    rm -rf prometheus
    rm -rf /var/log/app
    rm -f .env
    rm -f docker-compose.yml
    rm -f Dockerfile
    rm -f Dockerfile.celery
    rm -f requirements.txt
fi

# Remove scripts
if confirm "Do you want to remove management scripts?"; then
    echo -e "${YELLOW}Removing management scripts...${NC}"
    rm -f install.sh
    rm -f monitor.sh
    rm -f cert_manage.sh
    rm -f uninstall.sh
fi

# Clean up Docker
if confirm "Do you want to clean up unused Docker resources? (This will remove unused networks, images, and containers)"; then
    echo -e "${YELLOW}Cleaning up Docker resources...${NC}"
    docker system prune -f
fi

echo -e "${GREEN}Uninstallation completed!${NC}"
echo -e "${YELLOW}Note:${NC}"
echo -e "  - If you backed up certificates, they are stored in: $backup_dir"
echo -e "  - Docker system cleanup was performed"
echo -e "  - All application files and configurations have been removed"

# Make the script executable
chmod +x uninstall.sh 