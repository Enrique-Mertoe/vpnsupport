#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting VPN Service Installation...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}Creating required directories...${NC}"
mkdir -p prometheus
mkdir -p /var/log/app
mkdir -p dev_certs

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.production .env
    echo -e "${GREEN}Please edit .env file with your configuration${NC}"
fi

# Build and start containers
echo -e "${YELLOW}Building and starting containers...${NC}"
docker-compose build
docker-compose up -d

# Wait for services to start
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Check if services are running
echo -e "${YELLOW}Checking service status...${NC}"
docker-compose ps

echo -e "${GREEN}Installation completed!${NC}"
echo -e "${YELLOW}Access points:${NC}"
echo -e "  - Web Interface: http://localhost:5000"
echo -e "  - Flower (Celery Monitor): http://localhost:5555"
echo -e "  - Grafana: http://localhost:3000"
echo -e "  - Prometheus: http://localhost:9090"

# Make the script executable
chmod +x install.sh 