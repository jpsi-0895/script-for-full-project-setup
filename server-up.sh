#!/bin/bash
set -euo pipefail              # safer bash scripting

# ====================================================
# EC2 User Data Bootstrap Script - Server UP
# Tasks:
#   1. Update & Upgrade System
#   2. Install Basic Utilities
#   3. Start Web Server (Apache2)
#   4. Log setup for debugging
# ====================================================

# --- Logging setup ---
LOG_FILE="/var/log/user-data.log" #         
exec > >(tee -a $LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1 # Redirect stdout/stderr to log file and console    

echo "[INFO] Starting EC2 User Data script..."  # Initial log message

# --- Update & Upgrade ---
echo "[INFO] Updating system packages..."          
apt-get update -y  # Update package lists
apt-get upgrade -y  # Upgrade all packages

# --- Install Basic Tools ---
echo "[INFO] Installing utilities..."  # Install curl, wget, unzip, git, htop
apt-get install -y curl wget unzip git htop  # Install essential utilities  

# --- Install Apache2 Web Server ---
echo "[INFO] Installing Apache2..."  # Install Apache2 web server
apt-get install -y apache2  # Install Apache2
systemctl enable apache2  # Enable Apache2 to start on boot
systemctl start apache2  # Start Apache2 service

# --- Create a Test Page ---
echo "[INFO] Creating test page..."  # Create a simple HTML page
echo "<h1>Server is UP - $(hostname)</h1>" > /var/www/html/index.html  # Simple test page

# --- Status Check ---
echo "[INFO] Apache2 status:" # Check Apache2 status
systemctl status apache2 --no-pager # Display Apache2 status    

echo "[INFO] EC2 setup completed successfully!"     # Final log message
  # to check cat /var/log/user-data.log
