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

# ---- Create .env file ----
ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "📝 Creating $ENV_FILE ..."
    : > "$ENV_FILE"

    echo "Paste your environment variables (key=value). End with 'done' on a new line:"
    while IFS= read -r line; do
        [[ "$line" == "done" ]] && break
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        if [[ "$line" == *"="* ]]; then
            clean_line=$(echo "$line" | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
            echo "$clean_line" >> "$ENV_FILE"
        else
            echo "⚠️ Invalid format. Use key=value"
        fi
    done
fi

echo "✅ .env file ready:"
cat "$ENV_FILE"


# --- Step 7: Build Astro ---
echo "🏗️  Building Astro project..."
npm run build   # Build the Astro project

echo "✅ Deployment complete!"
npm run dev --host 0.0.0.0 --port 4321
