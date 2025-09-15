#!/bin/bash
# =========================================
# EC2 Ubuntu Bootstrap Script
# Purpose: Install all essential dependencies for a new EC2 Ubuntu instance
# Logs: /var/log/startup-versions.log
# Author: Pro Standard
# =========================================

set -euo pipefail  # Exit on error, undefined variable, or pipeline failure

LOG_FILE="/var/log/startup-versions.log"        
exec > >(tee -i $LOG_FILE) 2>&1 

echo "===== EC2 Bootstrap Started: $(date) ====="  

# ------------------------------
# 1. Update & Upgrade System
# ------------------------------
echo "Updating system packages..."      
sudo apt-get update -y  
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# ------------------------------
# 2. Install Essential Tools
# ------------------------------
echo "Installing essential tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    htop \
    tree \
    jq

# ------------------------------
# 3. Install Node.js & npm (LTS)
# ------------------------------
echo "Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# ------------------------------
# 4. Install MongoDB
# ------------------------------
echo "Installing MongoDB..."
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org
sudo systemctl enable mongod
sudo systemctl start mongod

# ------------------------------
# 5. Install PM2 globally (Node process manager)
# ------------------------------
echo "Installing PM2..."
sudo npm install -g pm2

# ------------------------------
# 6. Install Docker (Optional but Recommended)
# ------------------------------
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# ------------------------------
# 7. Log Versions
# ------------------------------
echo "===== Installed Versions ====="
echo "Node.js: $(node -v)"
echo "npm: $(npm -v)"
echo "MongoDB: $(mongod --version | head -n 1)"
echo "Git: $(git --version)"
echo "PM2: $(pm2 -v)"
echo "Docker: $(docker --version || echo 'Not installed')"

echo "===== EC2 Bootstrap Completed: $(date) ====="
