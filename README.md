# DVWA-QuickDeploy

This repository contains a fully automated bash script for installing and configuring **Damn Vulnerable Web Application (DVWA)** on **Kali Linux**. The script is designed to automate the installation of DVWA, configure the database, set permissions, and start the necessary services.

## Features

- **Automated Installation**: Automatically downloads and configures DVWA.
- **Database Setup**: Creates and configures the MySQL database and user.
- **Apache Configuration**: Updates PHP settings to allow `allow_url_fopen` and `allow_url_include`.
- **Customizable**: Allows user input for MySQL credentials, database name, and directory permissions.
- **Error Handling**: Built-in checks to handle pre-existing databases, users, and services.
- **Service Management**: Optionally restart Apache and MySQL services after setup.

## Prerequisites

Before running the script, ensure you have the following installed on your Kali Linux system:

- Apache
- MySQL
- PHP
- Git

### Installation of Required Packages

```bash
sudo apt update
sudo apt install apache2 mysql-server php php-mysql git -y
```

## Usage

To use the DVWA installation script, clone the repository and run the script with appropriate flags.

### Clone the Repository

```bash
git clone https://github.com/YourUsername/DVWA-QuickDeploy.git
cd DVWA-QuickDeploy
```

### Run the Script

```bash
sudo ./install_dvwa.sh


[-u mysql_user] [-p mysql_password] [-d db_name] [-r restart_services] [-s custom_permissions]
```

### Example

```bash
sudo ./install_dvwa.sh -u dvwa_user -p strong_password -d dvwa_db -r true -s 755
```

### Available Flags

- `-u`: MySQL username (default: `dvwa`)
- `-p`: MySQL password (default: `p@ssw0rd`)
- `-d`: Database name (default: `dvwa`)
- `-r`: Restart Apache and MySQL services after setup (default: `true`)
- `-s`: Custom directory permissions (default: `777`)

## Output

Upon successful installation, you should see the following output:

```
[*] Installation complete. Access DVWA at http://<your-ip-address>/DVWA/setup.php
[*] Open the URL in your browser and click 'Create / Reset Database' to finish setup.
[*] Default login: Username - admin, Password - password
```

### Access DVWA

Once the script has run successfully, you can access DVWA in your browser:

```
http://<your-ip-address>/DVWA/setup.php
```

### Default Credentials

- Username: `admin`
- Password: `password`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Sabih Qureshi (HexMan)

Feel free to contribute by submitting issues or pull requests to enhance this quick deployment solution.
