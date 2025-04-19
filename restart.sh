#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
check_docker() {
    if ! command_exists docker; then
        echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Docker daemon is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    if ! command_exists docker-compose; then
        echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
        exit 1
    fi
}

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

# Function to restart services
restart_services() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose down

    echo -e "${YELLOW}Starting services...${NC}"
    docker-compose up -d

    echo -e "${YELLOW}Waiting for services to start...${NC}"
    sleep 10

    echo -e "${YELLOW}Checking service status...${NC}"
    docker-compose ps
}

# Function to restart specific service
restart_specific_service() {
    local service=$1
    echo -e "${YELLOW}Restarting $service...${NC}"
    docker-compose restart $service
    
    echo -e "${YELLOW}Checking $service status...${NC}"
    docker-compose ps $service
}

# Main script
echo -e "${YELLOW}VPN Service Restart Script${NC}"

# Check prerequisites
check_docker
check_docker_compose

# Show current status
echo -e "${YELLOW}Current service status:${NC}"
docker-compose ps

# Ask for restart type
echo -e "\n${YELLOW}Choose restart option:${NC}"
echo "1) Restart all services"
echo "2) Restart specific service"
echo "3) Exit"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        if confirm "Are you sure you want to restart all services?"; then
            restart_services
            echo -e "${GREEN}All services have been restarted${NC}"
        else
            echo -e "${YELLOW}Restart cancelled${NC}"
        fi
        ;;
    2)
        echo -e "${YELLOW}Available services:${NC}"
        docker-compose config --services
        read -p "Enter service name to restart: " service_name
        if docker-compose config --services | grep -q "^$service_name$"; then
            if confirm "Are you sure you want to restart $service_name?"; then
                restart_specific_service $service_name
                echo -e "${GREEN}$service_name has been restarted${NC}"
            else
                echo -e "${YELLOW}Restart cancelled${NC}"
            fi
        else
            echo -e "${RED}Invalid service name${NC}"
        fi
        ;;
    3)
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "\n${YELLOW}Access points:${NC}"
echo -e "  - Web Interface: http://localhost:5000"
echo -e "  - Flower (Celery Monitor): http://localhost:5555"
echo -e "  - Grafana: http://localhost:3000"
echo -e "  - Prometheus: http://localhost:9090" 