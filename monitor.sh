#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
    docker-compose logs --tail=20 $service
}

echo -e "${YELLOW}Starting VPN Service Monitoring...${NC}"

# Check if services are running
echo -e "\n${YELLOW}Checking Service Status:${NC}"
check_service "Web Interface" "5000"
check_service "Flower (Celery Monitor)" "5555"
check_service "Grafana" "3000"
check_service "Prometheus" "9090"

# Show container status
echo -e "\n${YELLOW}Container Status:${NC}"
docker-compose ps

# Show recent logs
echo -e "\n${YELLOW}Recent Logs:${NC}"
show_logs "web"
show_logs "celery_worker"
show_logs "redis"

# Show resource usage
echo -e "\n${YELLOW}Resource Usage:${NC}"
docker stats --no-stream

# Show network status
echo -e "\n${YELLOW}Network Status:${NC}"
docker network inspect vpn_network

# Show volume usage
echo -e "\n${YELLOW}Volume Usage:${NC}"
docker system df -v

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