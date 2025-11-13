# PowerShell script to install MySQL locally
# Run this script as Administrator

# Download MySQL installer
Write-Host "This script will help you install MySQL locally"
Write-Host "Please follow these steps manually:"
Write-Host ""
Write-Host "1. Go to: https://dev.mysql.com/downloads/mysql/"
Write-Host "2. Download MySQL Community Server for Windows"
Write-Host "3. Run the installer and choose 'Server Only' configuration"
Write-Host "4. Set root password as: rootpassword"
Write-Host "5. Create database and user with these commands:"
Write-Host ""
Write-Host "MySQL Commands to run after installation:"
Write-Host "CREATE DATABASE myfinance;"
Write-Host "CREATE USER 'myfinance_user'@'localhost' IDENTIFIED BY 'myfinance_password';"
Write-Host "GRANT ALL PRIVILEGES ON myfinance.* TO 'myfinance_user'@'localhost';"
Write-Host "FLUSH PRIVILEGES;"
Write-Host ""
Write-Host "Then update backend/.env file:"
Write-Host "DB_HOST=localhost"
Write-Host "DB_PORT=3306"
Write-Host "DB_USERNAME=myfinance_user"
Write-Host "DB_PASSWORD=myfinance_password"