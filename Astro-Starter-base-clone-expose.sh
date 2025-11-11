#!/bin/bash
set -euo pipefail # Strict mode

# ================================
# Astro Deployment Script - Ubuntu
# ================================

echo "🚀 Starting Astro Deployment..."    

# --- Step 1: Update system ---
sudo apt update && sudo apt upgrade -y # Update package lists and upgrade installed packages

# --- Step 2: Install Node.js LTS & npm ---
if ! command -v node >/dev/null 2>&1; then # Check if Node.js is installed
  echo "📦 Installing Node.js LTS..." 
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - # Add NodeSource APT repository for Node.js LTS
  sudo apt install -y nodejs # Install Node.js and npm
fi

echo "✅ Node version: $(node -v)" #  Display installed Node.js version
echo "✅ npm version: $(npm -v)" # Display installed npm version

# --- Step 3: Install Git ---
if ! command -v git >/dev/null 2>&1; then # Check if Git is installed
  echo "📦 Installing Git..." # 
  sudo apt install -y git # Install Git
fi

# --- Step 4: Ask for GitHub repo URL ---
# Ask for GitHub repo URL
read -p "Enter GitHub repo URL: " REPO_URL #  Prompt user for GitHub repository URL

# Ask for target folder name
read -p "Enter target folder name (default: repo): " TARGET_DIR # Prompt user for target folder name
TARGET_DIR=${TARGET_DIR:-repo} # Default to 'repo' if no input

# Install git & npm if not present
if ! command -v git &>/dev/null; then # Check if Git is installed
    sudo apt-get update -y && sudo apt-get install -y git # Install Git
fi
if ! command -v npm &>/dev/null; then # Check if npm is installed
    sudo apt-get update -y && sudo apt-get install -y nodejs npm # Install Node.js and npm
fi

# Clone the repo
git clone "$REPO_URL" "$TARGET_DIR"# Clone the specified GitHub repository into the target directory

# Enter the repo folder
cd "$TARGET_DIR" #  Change directory to the cloned repository

# --- Step 6: Install Dependencies ---
echo "📦 Installing dependencies..." 
npm install # Install project dependencies

# --- Step 7: Build Astro ---
echo "🏗️  Building Astro project..."
npm run build  # Build the Astro project

# --- Step 8: Install Nginx ---
if ! command -v nginx >/dev/null 2>&1; then # Check if Nginx is installed
  echo "📦 Installing Nginx..."
  sudo apt install -y nginx  # Install Nginx
fi

# --- Step 9: Configure Nginx ---
NGINX_CONF="/etc/nginx/sites-available/astro" # Define Nginx configuration file path
sudo rm -f /etc/nginx/sites-enabled/default # Remove default Nginx site configuration

echo "⚙️  Configuring Nginx..."
sudo bash -c "cat > $NGINX_CONF" <<EOL # Create Nginx configuration for Astro project
server {  # Nginx server block
    listen 80; # Listen on port 80
    server_name _; # Accept requests for any server name

    root $(pwd)/dist; # Set root to Astro build output directory
    index index.html; # Set default index file

    location / { # Location block for root
        try_files \$uri /index.html; # Try to serve files, fallback to index.html for SPA routing
    } # End location block
}
EOL  # End of Nginx configuration

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/astro # Enable the new Nginx site configuration

# --- Step 10: Restart Nginx ---
sudo nginx -t  # Test Nginx configuration for syntax errors
sudo systemctl restart nginx # Restart Nginx to apply changes
sudo systemctl enable nginx # Enable Nginx to start on boot

# --- Step 11: Open Firewall ---
if command -v ufw >/dev/null 2>&1; then # Check if UFW is installed
  echo "🛡️  Configuring UFW to allow Nginx traffic..."
  sudo ufw allow 'Nginx Full' || true # Allow Nginx traffic through the firewall
fi

echo "✅ Deployment complete!"  # Indicate successful deployment
echo "🌐 Your Astro site should be accessible via your server's IP address."
npm run dev -- --host 0.0.0.0 --port 4321  # Start Astro development server accessible on all interfaces at port 4321
