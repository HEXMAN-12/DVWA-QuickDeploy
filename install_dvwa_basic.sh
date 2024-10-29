#!/bin/bash
# DVWA Installation Script for Kali Linux - Fully Automated
# Author: Sabih Qureshi 



set -e  # Exit on any error

set -x  # Show all commands being executed for logging



# Step 1: Download DVWA

DVWA_DIR="/var/www/html/DVWA"

if [ -d "$DVWA_DIR" ]; then

    echo "[*] DVWA directory already exists. Removing existing directory..."

    sudo rm -rf "$DVWA_DIR"

fi



echo "[*] Cloning DVWA repository to /var/www/html..."

cd /var/www/html/ || exit

sudo git clone https://github.com/digininja/DVWA



# Step 2: Configure DVWA - Set permissions and config file

echo "[*] Setting permissions for DVWA directory..."

sudo chmod -R 777 DVWA/



echo "[*] Copying default configuration to config.inc.php..."

cd DVWA/config || exit

sudo cp config.inc.php.dist config.inc.php



echo "[*] Editing the DVWA config file..."
# Updated lines to correctly set db_user and db_password
sudo sed -i "s/'db_user'/'db_user'/g" config.inc.php
sudo sed -i "s/'db_password'/'db_password'/g" config.inc.php



# Step 3: Configure Database - Start MySQL and set up the database

echo "[*] Starting MySQL service..."

sudo systemctl start mysql

sudo systemctl status mysql | grep Active



# Check if the database exists and drop it before creating

DB_EXISTS=$(sudo mysql -u root -e "SHOW DATABASES LIKE 'dvwa';" | grep -w dvwa)

if [ -n "$DB_EXISTS" ]; then
    echo "[*] Database 'dvwa' already exists. Dropping database..."
    sudo mysql -u root -e "DROP DATABASE dvwa;"
else
    echo "[*] Database 'dvwa' does not exist. Proceeding with setup..."
fi



# Check if the user exists and drop it before creating

USER_EXISTS=$(sudo mysql -u root -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'user' AND host = '127.0.0.1');" | tail -n 1)



if [ "$USER_EXISTS" -eq 1 ]; then

    echo "[*] MySQL user 'user' already exists. Dropping user..."

    sudo mysql -u root -e "DROP USER 'user'@'127.0.0.1';"

fi



echo "[*] Setting up DVWA database in MySQL..."

sudo mysql -u root <<MYSQL_SCRIPT

CREATE USER 'user'@'127.0.0.1' IDENTIFIED BY 'password';

CREATE DATABASE dvwa;

GRANT ALL PRIVILEGES ON dvwa.* TO 'user'@'127.0.0.1';

FLUSH PRIVILEGES;

MYSQL_SCRIPT



# Step 4: Configure Apache Server

PHP_VERSION=$(ls /etc/php/ | grep -oP '^[0-9]+\.[0-9]+')



if [[ -n "$PHP_VERSION" ]]; then

    echo "[*] PHP version detected: $PHP_VERSION"

else

    echo "[!] PHP version not found! Exiting."

    exit 1

fi



echo "[*] Editing PHP configuration file..."

sudo sed -i "s/allow_url_fopen = .*/allow_url_fopen = On/g" /etc/php/$PHP_VERSION/apache2/php.ini

sudo sed -i "s/allow_url_include = .*/allow_url_include = On/g" /etc/php/$PHP_VERSION/apache2/php.ini



echo "[*] Starting Apache server..."

sudo systemctl start apache2

sudo systemctl status apache2 | grep Active



# Step 5: Access DVWA

IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "[*] Installation complete. Access DVWA at http://$IP_ADDRESS/DVWA/setup.php"



echo "[*] Open the URL in your browser and click 'Create / Reset Database' to finish setup."

echo "[*] Default login: Username - admin, Password - password"

