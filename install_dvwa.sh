#!/bin/bash

# DVWA Installation Script for Kali Linux - Fully Automated
# Author: Sabih Qureshi
# This script installs DVWA, configures MySQL, sets up the Apache server, and performs additional checks.

# Function to display usage and help
usage() {
    echo "Usage: $0 [-u mysql_user] [-p mysql_password] [-d db_name] [-r restart_services] [-s custom_permissions]"
    echo "Options:"
    echo "  -u    MySQL user (default: 'dvwa')"
    echo "  -p    MySQL password (default: 'p@ssw0rd')"
    echo "  -d    Database name (default: 'dvwa')"
    echo "  -r    Restart services after installation (default: true)"
    echo "  -s    Custom directory permissions (default: 777)"
    exit 1
}

# Function to display banner
display_banner() {
    echo "  ┌───────────────────────────────────────┐"
    echo "  │        DVWA Automated Installer       │"
    echo "  └───────────────────────────────────────┘"
    sleep 2
}

# Default values for options
MYSQL_USER="dvwa"
MYSQL_PASSWORD="p@ssw0rd"
DB_NAME="dvwa"
RESTART_SERVICES=true
PERMISSIONS="777"

# Parse options
while getopts "u:p:d:r:s:h" option; do
    case "${option}" in
        u) MYSQL_USER=${OPTARG} ;;
        p) MYSQL_PASSWORD=${OPTARG} ;;
        d) DB_NAME=${OPTARG} ;;
        r) RESTART_SERVICES=${OPTARG} ;;
        s) PERMISSIONS=${OPTARG} ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Step 1: Display banner
display_banner

echo ""
echo ""

# Step 2: Download DVWA
DVWA_DIR="/var/www/html/DVWA"
if [ -d "$DVWA_DIR" ]; then
    echo "DVWA directory already exists. Removing existing directory..."
    sudo rm -rf "$DVWA_DIR"
fi

echo "Cloning DVWA repository to /var/www/html..."
cd /var/www/html/ || { echo "Failed to change directory to /var/www/html. Exiting."; exit 1; }
sudo git clone https://github.com/digininja/DVWA > /dev/null 2>&1
echo "DVWA repository cloned successfully."

echo ""
echo ""

# Step 3: Configure DVWA - Set permissions and config file
echo "Setting permissions for DVWA directory..."
sudo chmod -R $PERMISSIONS DVWA/

echo "Copying default configuration to config.inc.php..."
cd DVWA/config || { echo "Failed to change directory to DVWA/config. Exiting."; exit 1; }
sudo cp config.inc.php.dist config.inc.php

echo "Editing the DVWA config file with provided MySQL credentials..."
# sudo sed -i "s/'db_user'/'db_user', '$MYSQL_USER'/g" config.inc.php
# sudo sed -i "s/'db_password'/'db_password', '$MYSQL_PASSWORD'/g" config.inc.php

echo ""
echo ""

# Step 4: Configure Database - Start MySQL and set up the database
echo "Starting MySQL service..."
sudo systemctl start mysql > /dev/null 2>&1
sudo systemctl status mysql | grep Active

echo "Checking if DVWA database exists..."
DB_EXISTS=$(sudo mysql -u root -e "SHOW DATABASES LIKE '$DB_NAME';")

if echo "$DB_EXISTS" | grep -w "$DB_NAME" > /dev/null; then
    echo "Database '$DB_NAME' already exists. Dropping database..."
    sudo mysql -u root -e "DROP DATABASE $DB_NAME;" > /dev/null 2>&1
else
    echo "Database '$DB_NAME' does not exist. Proceeding with setup..."
fi

echo "Setting up DVWA database in MySQL..."
sudo mysql -u root <<MYSQL_SCRIPT
CREATE USER '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$MYSQL_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo ""
echo ""

# Step 5: Configure Apache Server
PHP_VERSION=$(ls /etc/php/ | grep -oP '^[0-9]+\.[0-9]+')

if [[ -n "$PHP_VERSION" ]]; then
    echo "PHP version detected: $PHP_VERSION"
else
    echo "PHP version not found! Exiting."
    exit 1
fi

echo "Editing PHP configuration file..."
sudo sed -i "s/allow_url_fopen = .*/allow_url_fopen = On/g" /etc/php/$PHP_VERSION/apache2/php.ini
sudo sed -i "s/allow_url_include = .*/allow_url_include = On/g" /etc/php/$PHP_VERSION/apache2/php.ini

echo "Starting Apache server..."
sudo systemctl start apache2 > /dev/null 2>&1
sudo systemctl status apache2 | grep Active

echo ""
echo ""

# Optionally restart services
if [ "$RESTART_SERVICES" = true ]; then
    echo "Restarting Apache and MySQL services..."
    sudo systemctl restart apache2 mysql > /dev/null 2>&1
fi

echo ""
echo ""
echo "  ┌───────────────────────────────────────────────────────────────────┐"
echo "  │                    DVWA Installation Successful!                  │"
echo "  │ Access DVWA at http://$(hostname -I | awk '{print $1}')/DVWA/setup.php                  │"
echo "  │ Open the URL in your browser and click 'Create / Reset Database'  │"
echo "  │ to finish setup.                                                  │"
echo "  │ Default login: Username - admin, Password - password              │"
echo "  └───────────────────────────────────────────────────────────────────┘"
echo ""
echo "                                Built By Sabih Qureshi."
echo ""
