#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if user has Docker permissions
check_docker_permissions() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker permission denied${NC}"
        echo -e "${YELLOW}Please run:${NC}"
        echo -e "  sudo usermod -aG docker \$USER"
        echo -e "  newgrp docker"
        echo -e "${YELLOW}Or run this script with sudo:${NC}"
        echo -e "  sudo $0"
        exit 1
    fi
}

# Function to check service status
check_service() {
    local service=$1
    local port=$2
    if curl -s "http://localhost:$port" > /dev/null; then
        echo -e "${GREEN}✓ $service is running on port $port${NC}"
    else
        echo -e "${RED}✗ $service is not running on port $port${NC}"
    fi
}

# Function to show logs
show_logs() {
    local service=$1
    echo -e "\n${YELLOW}=== $service Logs ===${NC}"
    if docker-compose logs --tail=20 $service 2>/dev/null; then
        return 0
    else
        echo -e "${RED}Error accessing logs for $service${NC}"
        return 1
    fi
}

echo -e "${YELLOW}Starting VPN Service Monitoring...${NC}"

# Check Docker permissions
check_docker_permissions

# Check if services are running
echo -e "\n${YELLOW}Checking Service Status:${NC}"
check_service "Web Interface" "5000"
check_service "Flower (Celery Monitor)" "5555"
check_service "Grafana" "3000"
check_service "Prometheus" "9090"

# Show container status
echo -e "\n${YELLOW}Container Status:${NC}"
if docker-compose ps 2>/dev/null; then
    echo -e "${GREEN}Container status retrieved successfully${NC}"
else
    echo -e "${RED}Error accessing container status${NC}"
fi

# Show recent logs
echo -e "\n${YELLOW}Recent Logs:${NC}"
show_logs "web"
show_logs "celery_worker"
show_logs "redis"

# Show resource usage
echo -e "\n${YELLOW}Resource Usage:${NC}"
if docker stats --no-stream 2>/dev/null; then
    echo -e "${GREEN}Resource usage retrieved successfully${NC}"
else
    echo -e "${RED}Error accessing resource usage${NC}"
fi

# Show network status
echo -e "\n${YELLOW}Network Status:${NC}"
if docker network inspect vpn_network 2>/dev/null; then
    echo -e "${GREEN}Network status retrieved successfully${NC}"
else
    echo -e "${RED}Error accessing network status${NC}"
fi

# Show volume usage
echo -e "\n${YELLOW}Volume Usage:${NC}"
if docker system df -v 2>/dev/null; then
    echo -e "${GREEN}Volume usage retrieved successfully${NC}"
else
    echo -e "${RED}Error accessing volume usage${NC}"
fi

echo -e "\n${GREEN}Monitoring completed!${NC}"
echo -e "${YELLOW}To view real-time logs, run:${NC}"
echo -e "  docker-compose logs -f [service_name]"
echo -e "${YELLOW}To access monitoring interfaces:${NC}"
echo -e "  - Web Interface: http://localhost:5000"
echo -e "  - Flower: http://localhost:5555"
echo -e "  - Grafana: http://localhost:3000"
echo -e "  - Prometheus: http://localhost:9090"

# Make the script executable
chmod +x monitor.sh 