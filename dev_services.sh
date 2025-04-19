#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service is running
check_service() {
    if pgrep -x "$1" >/dev/null; then
        echo -e "${GREEN}$1 is running${NC}"
        return 0
    else
        echo -e "${RED}$1 is not running${NC}"
        return 1
    fi
}

# Function to start Redis
start_redis() {
    echo -e "${YELLOW}Starting Redis...${NC}"
    if ! check_service "redis-server"; then
        if command -v redis-server >/dev/null; then
            redis-server --daemonize yes
            sleep 2
            if check_service "redis-server"; then
                echo -e "${GREEN}Redis started successfully${NC}"
            else
                echo -e "${RED}Failed to start Redis${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Redis is not installed. Please install Redis first.${NC}"
            echo -e "${YELLOW}For Windows:${NC}"
            echo "1. Download Redis from https://github.com/microsoftarchive/redis/releases"
            echo "2. Install and add to PATH"
            echo -e "${YELLOW}For Linux:${NC}"
            echo "sudo apt-get install redis-server"
            echo -e "${YELLOW}For macOS:${NC}"
            echo "brew install redis"
            exit 1
        fi
    fi
}

# Function to stop Redis
stop_redis() {
    echo -e "${YELLOW}Stopping Redis...${NC}"
    if check_service "redis-server"; then
        redis-cli shutdown
        echo -e "${GREEN}Redis stopped successfully${NC}"
    else
        echo -e "${YELLOW}Redis is not running${NC}"
    fi
}

# Function to check all services
check_all() {
    echo -e "${YELLOW}Checking services...${NC}"
    check_service "redis-server"
}

# Main script
case "$1" in
    start)
        start_redis
        ;;
    stop)
        stop_redis
        ;;
    check)
        check_all
        ;;
    *)
        echo "Usage: $0 {start|stop|check}"
        exit 1
        ;;
esac 