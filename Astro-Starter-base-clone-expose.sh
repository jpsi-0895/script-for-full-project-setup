#!/bin/bash
set -euo pipefail  # Enable strict error handling

# ================================
# Astro Deployment Script - Ubuntu
# ================================

echo "🚀 Starting Astro Deployment..." 

# --- Step 1: Update system ---
sudo apt update && sudo apt upgrade -y  # Update package lists and upgrade installed packages

# --- Step 2: Install Node.js LTS & npm ---
if ! command -v node >/dev/null 2>&1; then  # Check if Node.js is installed
  echo "📦 Installing Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -  # Add NodeSource repository
  sudo apt install -y nodejs   # Install Node.js and npm
fi

echo "✅ Node version: $(node -v)"
echo "✅ npm version: $(npm -v)"

# --- Step 3: Install Git ---
if ! command -v git >/dev/null 2>&1; then  # Check if Git is installed
  echo "📦 Installing Git..."   
  sudo apt install -y git    # Install Git
fi

# --- Step 4: Ask for GitHub repo URL ---
# Ask for GitHub repo URL
read -p "Enter GitHub repo URL: " REPO_URL  

# Ask for target folder name
read -p "Enter target folder name (default: repo): " TARGET_DIR   # Optional: specify target folder name
TARGET_DIR=${TARGET_DIR:-repo}   # Default to 'repo' if not provided

# Install git & npm if not present
if ! command -v git &>/dev/null; then  # Install git if not present
    sudo apt-get update -y && sudo apt-get install -y git   # Install Git
fi
if ! command -v npm &>/dev/null; then   # Install npm if not present
    sudo apt-get update -y && sudo apt-get install -y nodejs npm  # Install Node.js and npm
fi

# Clone the repo
git clone "$REPO_URL" "$TARGET_DIR"  # Clone the specified GitHub repo

# Enter the repo folder
cd "$TARGET_DIR"    # Change to the target directory

# --- Step 6: Install Dependencies ---
echo "📦 Installing dependencies..."
npm install   # Install project dependencies

# --- Step 7: Build Astro ---
echo "🏗️  Building Astro project..."
npm run build   # Build the Astro project

# --- Step 8: Install Nginx ---
if ! command -v nginx >/dev/null 2>&1; then  # Check if Nginx is installed
  echo "📦 Installing Nginx..."    
  sudo apt install -y nginx   # Install Nginx
fi

# --- Step 9: Configure Nginx ---
NGINX_CONF="/etc/nginx/sites-available/astro"  # Nginx configuration file path
sudo rm -f /etc/nginx/sites-enabled/default  # Remove default site

echo "⚙️  Configuring Nginx..."
sudo bash -c "cat > $NGINX_CONF" <<EOL   
server {
    listen 80;
    server_name _;

    root $(pwd)/dist;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }
}
EOL

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/astro  # Enable the new site

# --- Step 10: Restart Nginx ---
sudo nginx -t   # Test Nginx configuration
sudo systemctl restart nginx  # Restart Nginx to apply changes
sudo systemctl enable nginx # Enable Nginx to start on boot

# --- Step 11: Open Firewall ---
if command -v ufw >/dev/null 2>&1; then # Check if UFW is installed
  sudo ufw allow 'Nginx Full' || true
fi

echo "✅ Deployment complete!"
npm run dev -- --host 0.0.0.0 --port 4321
