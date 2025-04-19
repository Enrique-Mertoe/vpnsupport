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

# Function to install required packages
install_requirements() {
    echo -e "${YELLOW}Installing required packages...${NC}"
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y nginx certbot python3-certbot-nginx
    elif command_exists yum; then
        sudo yum install -y nginx certbot python3-certbot-nginx
    else
        echo -e "${RED}Unsupported package manager${NC}"
        exit 1
    fi
}

# Function to check if domain is valid
check_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to configure Nginx for a domain
configure_nginx() {
    local domain=$1
    local config_file="/etc/nginx/sites-available/$domain"
    
    echo -e "${YELLOW}Configuring Nginx for $domain...${NC}"
    
    # Create Nginx configuration
    sudo tee "$config_file" > /dev/null << EOF
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
    sudo ln -sf "$config_file" "/etc/nginx/sites-enabled/"
    
    # Test Nginx configuration
    if sudo nginx -t; then
        sudo systemctl reload nginx
        echo -e "${GREEN}Nginx configuration for $domain is valid and reloaded${NC}"
    else
        echo -e "${RED}Nginx configuration test failed${NC}"
        exit 1
    fi
}

# Function to obtain SSL certificate
obtain_ssl() {
    local domain=$1
    echo -e "${YELLOW}Obtaining SSL certificate for $domain...${NC}"
    sudo certbot --nginx -d "$domain" --non-interactive --agree-tos --email admin@$domain
}

# Function to add a domain
add_domain() {
    local domain
    read -p "Enter domain name (e.g., vpn.example.com): " domain
    
    if check_domain "$domain"; then
        configure_nginx "$domain"
        obtain_ssl "$domain"
        echo -e "${GREEN}Domain $domain added successfully${NC}"
    else
        echo -e "${RED}Invalid domain format${NC}"
        exit 1
    fi
}

# Function to remove a domain
remove_domain() {
    local domain
    read -p "Enter domain name to remove: " domain
    
    if [ -f "/etc/nginx/sites-available/$domain" ]; then
        echo -e "${YELLOW}Removing domain $domain...${NC}"
        sudo rm -f "/etc/nginx/sites-available/$domain"
        sudo rm -f "/etc/nginx/sites-enabled/$domain"
        sudo certbot delete --cert-name "$domain"
        sudo systemctl reload nginx
        echo -e "${GREEN}Domain $domain removed successfully${NC}"
    else
        echo -e "${RED}Domain $domain not found${NC}"
    fi
}

# Function to list all domains
list_domains() {
    echo -e "${YELLOW}List of configured domains:${NC}"
    ls -1 /etc/nginx/sites-available/ 2>/dev/null || echo "No domains configured"
}

# Function to renew all SSL certificates
renew_certificates() {
    echo -e "${YELLOW}Renewing SSL certificates...${NC}"
    sudo certbot renew
    sudo systemctl reload nginx
    echo -e "${GREEN}SSL certificates renewed successfully${NC}"
}

# Main menu
while true; do
    echo -e "\n${YELLOW}Domain Management Menu${NC}"
    echo "1. Add a new domain"
    echo "2. Remove a domain"
    echo "3. List all domains"
    echo "4. Renew SSL certificates"
    echo "5. Exit"
    read -p "Select an option (1-5): " choice

    case $choice in
        1)
            add_domain
            ;;
        2)
            remove_domain
            ;;
        3)
            list_domains
            ;;
        4)
            renew_certificates
            ;;
        5)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
done

# Make the script executable
chmod +x domain_manager.sh 