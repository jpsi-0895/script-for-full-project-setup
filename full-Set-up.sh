#!/bin/bash
# =========================================
# EC2 Ubuntu Dependency Bootstrap Script
# =========================================
# Author: DevOps Standard (2025 Edition)
# Target: Ubuntu 24.04 LTS (Noble Numbat) on AWS EC2
# =========================================

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/var/log/ec2-bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Starting Dependency Bootstrap: $(date) ====="

# --- Helper Functions ---
check_command() {
  if command -v "$1" &>/dev/null; then
    echo "[OK] $1 -> $($1 --version 2>&1 | head -n 1)"
  else
    echo "[ERROR] $1 not installed properly"
    exit 1
  fi
}

check_service() {
  local service=$1
  if systemctl is-active --quiet "$service"; then
    echo "[OK] $service service is running"
  else
    echo "[ERROR] $service service is NOT running"
    exit 1
  fi
}

# --- System Update ---
echo ">>> Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# --- Core Utilities ---
echo ">>> Installing core utilities..."
sudo apt-get install -y \
  build-essential \
  curl \
  wget \
  git \
  unzip \
  zip \
  htop \
  ufw \
  fail2ban \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common

# --- Node.js (LTS) + npm + PM2 ---
echo ">>> Installing Node.js (LTS), npm, and PM2..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Upgrade npm to latest stable
sudo npm install -g npm >/dev/null 2>&1

# Install PM2 (quiet, no ASCII banners)
export PM2_NO_INTERACTION=1
export PM2_NO_ASCII=1
sudo npm install -g pm2 >/dev/null 2>&1

echo "[INFO] Node.js version: $(node -v)"
echo "[INFO] npm version: $(npm -v)"
echo "[INFO] PM2 version: $(pm2 -v)"

# Setup PM2 startup script
echo ">>> Configuring PM2 to auto-start on boot..."
pm2 startup systemd -u $USER --hp $HOME >/dev/null 2>&1 || true
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME >/dev/null 2>&1 || true

# --- MongoDB (Latest Stable 8.0 for Noble) ---
echo ">>> Installing MongoDB 8.0..."
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
  https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update -y
sudo apt-get install -y mongodb-org
sudo systemctl enable --now mongod

# --- Python 3 + pip ---
echo ">>> Installing Python3 & pip..."
sudo apt-get install -y python3 python3-pip

# --- Docker & Docker Compose ---
echo ">>> Installing Docker & Docker Compose..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ubuntu

# --- Nginx (latest stable) ---
echo ">>> Installing Nginx..."
sudo apt-get install -y nginx
sudo systemctl enable --now nginx

# --- Versions & Health Check ---
echo "===== Installed Versions ====="
check_command node
check_command npm
check_command pm2
check_command python3
check_command pip3
check_command docker
check_command nginx

echo "===== Service Status ====="
check_service mongod
check_service nginx
check_service docker

echo "===== Bootstrap Completed Successfully: $(date) ====="
echo "[INFO] Full logs available at $LOG_FILE"
