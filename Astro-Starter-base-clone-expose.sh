#!/bin/bash
set -euo pipefail

# ================================
# Astro Deployment Script - Ubuntu
# ================================

echo "🚀 Starting Astro Deployment..."

# --- Step 1: Update system ---
sudo apt update && sudo apt upgrade -y

# --- Step 2: Install Node.js LTS & npm ---
if ! command -v node >/dev/null 2>&1; then
  echo "📦 Installing Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
fi

echo "✅ Node version: $(node -v)"
echo "✅ npm version: $(npm -v)"

# --- Step 3: Install Git ---
if ! command -v git >/dev/null 2>&1; then
  echo "📦 Installing Git..."
  sudo apt install -y git
fi

# --- Step 4: Ask for GitHub repo URL ---
# Ask for GitHub repo URL
read -p "Enter GitHub repo URL: " REPO_URL

# Ask for target folder name
read -p "Enter target folder name (default: repo): " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-repo}

# Install git & npm if not present
if ! command -v git &>/dev/null; then
    sudo apt-get update -y && sudo apt-get install -y git
fi
if ! command -v npm &>/dev/null; then
    sudo apt-get update -y && sudo apt-get install -y nodejs npm
fi

# Clone the repo
git clone "$REPO_URL" "$TARGET_DIR"

# Enter the repo folder
cd "$TARGET_DIR" 

# --- Step 6: Install Dependencies ---
echo "📦 Installing dependencies..."
npm install

# --- Step 7: Build Astro ---
echo "🏗️  Building Astro project..."
npm run build

# --- Step 8: Install Nginx ---
if ! command -v nginx >/dev/null 2>&1; then
  echo "📦 Installing Nginx..."
  sudo apt install -y nginx
fi

# --- Step 9: Configure Nginx ---
NGINX_CONF="/etc/nginx/sites-available/astro"
sudo rm -f /etc/nginx/sites-enabled/default

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

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/astro

# --- Step 10: Restart Nginx ---
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# --- Step 11: Open Firewall ---
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 'Nginx Full' || true
fi

echo "✅ Deployment complete!"
npm run dev -- --host 0.0.0.0 --port 4321

