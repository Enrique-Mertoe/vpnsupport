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

# Function to check OpenVPN server
check_openvpn() {
    echo -e "${YELLOW}Checking OpenVPN server...${NC}"

    # Check if OpenVPN is installed
    if ! command_exists openvpn; then
        echo -e "${RED}OpenVPN is not installed.${NC}"
        echo -e "${YELLOW}Recommended installation method:${NC}"
        echo -e "  wget https://git.io/vpn -O openvpn-install.sh"
        echo -e "  chmod +x openvpn-install.sh"
        echo -e "  sudo ./openvpn-install.sh"
        echo -e "\n${YELLOW}Alternative installation methods:${NC}"
        if command_exists apt-get; then
            echo "  sudo apt-get update && sudo apt-get install -y openvpn"
        elif command_exists yum; then
            echo "  sudo yum install -y openvpn"
        else
            echo "  Please install OpenVPN using your package manager"
        fi
        exit 1
    fi

    # Check if OpenVPN service is running
    if ! systemctl is-active --quiet openvpn; then
        echo -e "${RED}OpenVPN service is not running.${NC}"
        echo -e "${YELLOW}To start OpenVPN, run:${NC}"
        echo "  sudo systemctl start openvpn"
        exit 1
    fi

    # Check for server configuration
    if [ ! -f "/etc/openvpn/server.conf" ]; then
        echo -e "${RED}OpenVPN server configuration not found.${NC}"
        echo -e "${YELLOW}Please ensure you have a valid server configuration at /etc/openvpn/server.conf${NC}"
        echo -e "${YELLOW}You can use the recommended installer script to set this up:${NC}"
        echo -e "  wget https://git.io/vpn -O openvpn-install.sh"
        echo -e "  chmod +x openvpn-install.sh"
        echo -e "  sudo ./openvpn-install.sh"
        exit 1
    fi

    # Check for easy-rsa
    if [ ! -d "/etc/openvpn/easy-rsa" ]; then
        echo -e "${RED}Easy-RSA directory not found.${NC}"
        echo -e "${YELLOW}Please ensure easy-rsa is properly installed and configured.${NC}"
        echo -e "${YELLOW}You can use the recommended installer script to set this up:${NC}"
        echo -e "  wget https://git.io/vpn -O openvpn-install.sh"
        echo -e "  chmod +x openvpn-install.sh"
        echo -e "  sudo ./openvpn-install.sh"
        exit 1
    fi

    # Check for CA certificate
    if [ ! -f "/etc/openvpn/easy-rsa/pki/ca.crt" ]; then
        echo -e "${RED}CA certificate not found.${NC}"
        echo -e "${YELLOW}Please ensure you have generated a CA certificate.${NC}"
        echo -e "${YELLOW}You can use the recommended installer script to set this up:${NC}"
        echo -e "  wget https://git.io/vpn -O openvpn-install.sh"
        echo -e "  chmod +x openvpn-install.sh"
        echo -e "  sudo ./openvpn-install.sh"
        exit 1
    fi

    echo -e "${GREEN}OpenVPN server check passed${NC}"
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

echo -e "${YELLOW}Starting VPN Service Installation...${NC}"

# Check OpenVPN server first
#check_openvpn

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Please install Python 3 first.${NC}"
    exit 1
fi

# Check if virtualenv is installed
if ! command -v virtualenv &> /dev/null; then
    echo -e "${YELLOW}Installing virtualenv...${NC}"
    pip install virtualenv
fi

# Create and activate virtual environment
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    virtualenv venv
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate

# Install Python dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
pip install -r requirements.txt

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
echo -e "\n${YELLOW}Development Environment:${NC}"
echo -e "  - Virtual environment is activated"
echo -e "  - To deactivate virtual environment, run: deactivate"
echo -e "  - To reactivate virtual environment, run: source venv/bin/activate"

# Ask about domain configuration
if confirm "Would you like to configure a domain for the VPN service now?"; then
    echo -e "${YELLOW}Running domain configuration...${NC}"
    ./domain_manager.sh
else
    echo -e "${YELLOW}You can configure domains later by running:${NC}"
    echo -e "  ./domain_manager.sh"
fi

# Make the script executable
chmod +x install.sh 