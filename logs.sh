#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Docker daemon is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Function to list available containers
list_containers() {
    echo -e "${YELLOW}Available containers:${NC}"
    local containers=($(docker ps --format '{{.Names}}'))

    if [ ${#containers[@]} -eq 0 ]; then
        echo -e "${RED}No running containers found${NC}"
        echo -e "${YELLOW}Please start your containers first using:${NC}"
        echo "docker-compose up -d"
        exit 1
    fi

    for i in "${!containers[@]}"; do
        echo "$((i+1))) ${containers[$i]}"
    done
}

# Function to select container
select_container() {
    local containers=($(docker ps --format '{{.Names}}'))
    local num_containers=${#containers[@]}

    while true; do
        read -p "Enter container number (1-$num_containers): " choice

        if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le $num_containers ]; then
            echo "${containers[$((choice-1))]}"
            return 0
        else
            echo -e "${RED}Invalid choice. Please enter a number between 1 and $num_containers${NC}"
        fi
    done
}

# Function to show logs with formatting
show_logs() {
    local container_name=$1
    local log_level=$2

    echo -e "${YELLOW}Showing logs for $container_name${NC}"
    echo -e "${BLUE}Log level: $log_level${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo -e "${GREEN}----------------------------------------${NC}"

    # Format log levels with colors
    local level_colors=(
        "DEBUG:${BLUE}"
        "INFO:${GREEN}"
        "WARNING:${YELLOW}"
        "ERROR:${RED}"
        "CRITICAL:${RED}"
    )

    # Create color filter
    local color_filter=""
    for level_color in "${level_colors[@]}"; do
        IFS=':' read -r level color <<< "$level_color"
        color_filter+="s/\[$level\]/${color}[$level]${NC}/g;"
    done

    # Show logs with formatting
    if [ "$log_level" = "ALL" ]; then
        docker logs -f $container_name 2>&1 | \
            sed -u -e "$color_filter" \
                  -e 's/\[\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)\]/\1/g' \
                  -e 's/\[\([A-Z]\+\)\]/\1/g' \
                  -e 's/\[\([^]]*\)\]/\1/g'
    else
        docker logs -f $container_name 2>&1 | \
            grep -E "\[$log_level\]" | \
            sed -u -e "$color_filter" \
                  -e 's/\[\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)\]/\1/g' \
                  -e 's/\[\([A-Z]\+\)\]/\1/g' \
                  -e 's/\[\([^]]*\)\]/\1/g'
    fi
}

# Main script
echo -e "${YELLOW}Flask Application Log Viewer${NC}"

# Check Docker
check_docker

# List and select container
list_containers
container_name=$(select_container)

# Show menu
echo -e "\n${YELLOW}Choose log level:${NC}"
echo "1) DEBUG"
echo "2) INFO"
echo "3) WARNING"
echo "4) ERROR"
echo "5) CRITICAL"
echo "6) ALL"
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        show_logs "$container_name" "DEBUG"
        ;;
    2)
        show_logs "$container_name" "INFO"
        ;;
    3)
        show_logs "$container_name" "WARNING"
        ;;
    4)
        show_logs "$container_name" "ERROR"
        ;;
    5)
        show_logs "$container_name" "CRITICAL"
        ;;
    6)
        show_logs "$container_name" "ALL"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac 