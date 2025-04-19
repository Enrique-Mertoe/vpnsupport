#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a client exists
check_client() {
    local client_name=$1
    if [ -d "dev_certs/$client_name" ]; then
        return 0
    else
        return 1
    fi
}

# Function to list all clients
list_clients() {
    echo -e "${YELLOW}List of all clients:${NC}"
    if [ -d "dev_certs" ]; then
        ls -1 dev_certs
    else
        echo -e "${RED}No clients found${NC}"
    fi
}

# Function to show certificate details
show_cert_details() {
    local client_name=$1
    if check_client "$client_name"; then
        echo -e "${YELLOW}Certificate details for $client_name:${NC}"
        if [ -f "dev_certs/$client_name/$client_name.crt" ]; then
            openssl x509 -in "dev_certs/$client_name/$client_name.crt" -text -noout
        else
            echo -e "${RED}Certificate file not found${NC}"
        fi
    else
        echo -e "${RED}Client $client_name does not exist${NC}"
    fi
}

# Function to revoke a certificate
revoke_cert() {
    local client_name=$1
    if check_client "$client_name"; then
        echo -e "${YELLOW}Revoking certificate for $client_name...${NC}"
        # Add certificate to CRL
        docker-compose exec web python -c "from app import create_app; from app.tasks import revoke_certificate; app = create_app(); with app.app_context(): revoke_certificate.delay('$client_name')"
        echo -e "${GREEN}Certificate revocation initiated${NC}"
    else
        echo -e "${RED}Client $client_name does not exist${NC}"
    fi
}

# Function to backup certificates
backup_certs() {
    local backup_dir="cert_backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Creating backup in $backup_dir...${NC}"
    mkdir -p "$backup_dir"
    cp -r dev_certs/* "$backup_dir/"
    echo -e "${GREEN}Backup completed${NC}"
}

# Main menu
while true; do
    echo -e "\n${YELLOW}OpenVPN Certificate Management${NC}"
    echo "1. List all clients"
    echo "2. Show certificate details"
    echo "3. Revoke certificate"
    echo "4. Backup certificates"
    echo "5. Exit"
    read -p "Select an option (1-5): " choice

    case $choice in
        1)
            list_clients
            ;;
        2)
            read -p "Enter client name: " client_name
            show_cert_details "$client_name"
            ;;
        3)
            read -p "Enter client name to revoke: " client_name
            revoke_cert "$client_name"
            ;;
        4)
            backup_certs
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
chmod +x cert_manage.sh 