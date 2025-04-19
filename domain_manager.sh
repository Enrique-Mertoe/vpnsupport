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

# Function to check and install Nginx
check_nginx() {
    echo -e "${YELLOW}Checking Nginx installation...${NC}"

    if ! command_exists nginx; then
        echo -e "${YELLOW}Nginx is not installed. Installing Nginx...${NC}"

        # Check package manager and install Nginx
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y nginx
        elif command_exists yum; then
            sudo yum install -y nginx
        else
            echo -e "${RED}Could not determine package manager. Please install Nginx manually.${NC}"
            exit 1
        fi

        # Create necessary directories if they don't exist
        sudo mkdir -p /etc/nginx/sites-available
        sudo mkdir -p /etc/nginx/sites-enabled

        # Configure Nginx to include sites-enabled
        if [ ! -f "/etc/nginx/nginx.conf" ]; then
            echo -e "${RED}Nginx configuration file not found.${NC}"
            exit 1
        fi

        # Check if sites-enabled is already included
        if ! grep -q "include /etc/nginx/sites-enabled/\*;" /etc/nginx/nginx.conf; then
            echo -e "${YELLOW}Configuring Nginx to include sites-enabled...${NC}"
            sudo sed -i '/http {/a \    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
        fi

        # Start Nginx if not running
        if ! systemctl is-active --quiet nginx; then
            echo -e "${YELLOW}Starting Nginx service...${NC}"
            sudo systemctl start nginx
            sudo systemctl enable nginx
        fi

        echo -e "${GREEN}Nginx installation and configuration completed${NC}"
    else
        echo -e "${GREEN}Nginx is already installed${NC}"

        # Ensure directories exist
        sudo mkdir -p /etc/nginx/sites-available
        sudo mkdir -p /etc/nginx/sites-enabled

        # Check if sites-enabled is included
        if ! grep -q "include /etc/nginx/sites-enabled/\*;" /etc/nginx/nginx.conf; then
            echo -e "${YELLOW}Configuring Nginx to include sites-enabled...${NC}"
            sudo sed -i '/http {/a \    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
            sudo systemctl restart nginx
        fi
    fi

    # Test Nginx configuration
    echo -e "${YELLOW}Testing Nginx configuration...${NC}"
    if ! sudo nginx -t; then
        echo -e "${RED}Nginx configuration test failed${NC}"
        exit 1
    fi
}

# Function to check if Certbot is installed
check_certbot() {
    echo -e "${YELLOW}Checking Certbot installation...${NC}"

    if ! command_exists certbot; then
        echo -e "${YELLOW}Certbot is not installed. Installing Certbot...${NC}"

        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y certbot python3-certbot-nginx
        elif command_exists yum; then
            sudo yum install -y certbot python3-certbot-nginx
        else
            echo -e "${RED}Could not determine package manager. Please install Certbot manually.${NC}"
            exit 1
        fi

        echo -e "${GREEN}Certbot installation completed${NC}"
    else
        echo -e "${GREEN}Certbot is already installed${NC}"
    fi
}

# Function to check if a domain is valid
is_valid_domain() {
    local domain=$1
    # Basic domain validation
    if [[ $domain =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](\.[a-zA-Z]{2,})+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a domain is already configured
is_domain_configured() {
    local domain=$1
    if [ -f "/etc/nginx/sites-enabled/$domain" ]; then
        return 0
    else
        return 1
    fi
}

# Function to configure domain
configure_domain() {
    local domain=$1
    local subdomain=$2

    echo -e "${YELLOW}Configuring Nginx for $domain...${NC}"

    # Create Nginx configuration
    cat << EOF | sudo tee /etc/nginx/sites-available/$domain > /dev/null
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /flower {
        proxy_pass http://localhost:5555;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /grafana {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /prometheus {
        proxy_pass http://localhost:9090;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    # Create symbolic link
    sudo ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

    # Test Nginx configuration
    if ! sudo nginx -t; then
        echo -e "${RED}Nginx configuration test failed${NC}"
        exit 1
    fi

    # Reload Nginx
    sudo systemctl reload nginx

    echo -e "${GREEN}Domain configuration completed${NC}"
}

# Function to obtain SSL certificate
obtain_ssl() {
    local domain=$1

    echo -e "${YELLOW}Obtaining SSL certificate for $domain...${NC}"

    if sudo certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain; then
        echo -e "${GREEN}SSL certificate obtained successfully${NC}"
    else
        echo -e "${RED}Failed to obtain SSL certificate${NC}"
        exit 1
    fi
}

# Function to remove domain
remove_domain() {
    local domain=$1

    echo -e "${YELLOW}Removing domain $domain...${NC}"

    # Remove SSL certificate
    sudo certbot delete --cert-name $domain

    # Remove Nginx configuration
    sudo rm -f /etc/nginx/sites-enabled/$domain
    sudo rm -f /etc/nginx/sites-available/$domain

    # Reload Nginx
    sudo systemctl reload nginx

    echo -e "${GREEN}Domain removed successfully${NC}"
}

# Function to list configured domains
list_domains() {
    echo -e "${YELLOW}Configured domains:${NC}"
    ls -1 /etc/nginx/sites-enabled/
}

# Function to renew SSL certificates
renew_ssl() {
    echo -e "${YELLOW}Renewing SSL certificates...${NC}"

    if sudo certbot renew; then
        echo -e "${GREEN}SSL certificates renewed successfully${NC}"
    else
        echo -e "${RED}Failed to renew SSL certificates${NC}"
        exit 1
    fi
}

# Main script
echo -e "${YELLOW}Domain Management Script${NC}"

# Check prerequisites
check_nginx
check_certbot

# Show menu
while true; do
    echo -e "\n${YELLOW}Choose an option:${NC}"
    echo "1) Add new domain"
    echo "2) Remove domain"
    echo "3) List configured domains"
    echo "4) Renew SSL certificates"
    echo "5) Exit"
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            read -p "Enter domain name: " domain
            read -p "Enter subdomain (optional, press Enter to skip): " subdomain

            if [ -z "$domain" ]; then
                echo -e "${RED}Domain name is required${NC}"
                continue
            fi

            if ! is_valid_domain "$domain"; then
                echo -e "${RED}Invalid domain name${NC}"
                continue
            fi

            if is_domain_configured "$domain"; then
                echo -e "${RED}Domain is already configured${NC}"
                continue
            fi

            configure_domain "$domain" "$subdomain"
            obtain_ssl "$domain"
            ;;
        2)
            read -p "Enter domain name to remove: " domain

            if [ -z "$domain" ]; then
                echo -e "${RED}Domain name is required${NC}"
                continue
            fi

            if ! is_domain_configured "$domain"; then
                echo -e "${RED}Domain is not configured${NC}"
                continue
            fi

            remove_domain "$domain"
            ;;
        3)
            list_domains
            ;;
        4)
            renew_ssl
            ;;
        5)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
done