
# Svelte Dev Deployment Script

This script automates the setup of a Svelte development environment by performing the following tasks:

1. Installs necessary tools (Git, Node.js).
2. Clones a repository.
3. Installs project dependencies.
4. Creates a `.env` file (if it doesn't exist).
5. Starts the Svelte development server.

```sh
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Svelte Dev Deployment Script..."

# Detect if sudo needed
SUDO_CMD=""
if [[ $(id -u) -ne 0 ]]; then
  SUDO_CMD="sudo"
fi

# Check required commands
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Install git
if ! has_cmd git; then
  echo "📦 Installing Git..."
  $SUDO_CMD apt update -y
  $SUDO_CMD apt install -y git
fi

# Install Node.js LTS
if ! has_cmd node || ! has_cmd npm; then
  echo "📦 Installing Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | $SUDO_CMD -E bash -
  $SUDO_CMD apt install -y nodejs
fi

echo "✅ Node: $(node -v)  npm: $(npm -v)"

# Ask repo URL
read -p "Enter Git repo URL: " REPO_URL
read -p "Enter target directory (default: svelte-app): " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-svelte-app}

# Ask port
read -p "Enter port to expose (default: 5173): " PORT
PORT=${PORT:-5173}

# Clone repo
if [[ -d "$TARGET_DIR" ]]; then
  echo "⚠️ Directory exists. Pulling latest changes..."
  cd "$TARGET_DIR"
  git pull || true
else
  echo "📥 Cloning project..."
  git clone "$REPO_URL" "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create .env file (optional)
ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "📝 Creating .env file. Type KEY=VALUE and 'done' to finish:"
  : > "$ENV_FILE"
  while IFS= read -r line; do
    [[ "$line" == "done" ]] && break
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "$line" >> "$ENV_FILE"
  done
fi

echo "📂 .env content:"
cat "$ENV_FILE"

# Start dev server
echo "🚀 Starting Svelte Dev Server on 0.0.0.0:${PORT}"
echo "Visit: http://your-server-ip:${PORT}"

#npm run dev -- --host 0.0.0.0 --port "$PORT"




#npm run dev -- --host 0.0.0.0 --port 5173
# npm run dev -- --host 0.0.0.0 --port 4321
npm run build
npm run preview -- --host 0.0.0.0 --port "$PORT"
```