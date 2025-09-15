#!/bin/bash
# Bootstrap script for EC2 instance setup
# Logs versions of key software and updates the system  
ste -eno pipefail  # Exit on error, undefined variable, or pipeline failure 
LOG_FILE="/var/log/startup-versions.log"         #  Log file path
exec > >(tee -i $LOG_FILE) 2>&1   # Redirect stdout and stderr to log file
echo "===== EC2 Bootstrap Started: $(date) ====="  # Start log entry

# ------------------------------
# 1. Update & Upgrade System
# ------------------------------
echo "updating the system packages..."  # Log update start
sudo apt-get update -y # Update package list
sudo apt-get upgrade -y  # Upgrade installed packages
sudo apt-get dist-upgrade -y  # Perform distribution upgrade
sudo apt-get autoremove -y # Remove unnecessary packages
echo "System packages updated." # Log update completion
# ------------------------------
# 2. Log Software Versions
# ------------------------------
echo "Logging software versions..."
echo "Python Version: $(python3 --version 2>&1 || echo 'Python3 not installed')" # Log Python version
echo "Node.js Version: $(node --version 2>&1 || echo 'Node.js not installed')" # Log Node.js version
echo "npm Version: $(npm --version 2>&1 || echo 'npm not installed')" # Log npm version
echo "Java Version: $(java -version 2>&1 | head -n 1 || echo 'Java not installed')" # Log Java version
echo "Maven Version: $(mvn -version 2>&1 | head -n 1 || echo 'Maven not installed')" # Log Maven version
echo "Gradle Version: $(gradle --version 2>&1 | head -n 1 || echo 'Gradle not installed')" # Log Gradle version
echo "Go Version: $(go version 2>&1 || echo 'Go not installed')" # Log Go version
echo "Ruby Version: $(ruby --version 2>&1 || echo 'Ruby not installed')" # Log Ruby version
echo "Perl Version: $(perl --version 2>&1 | head -n 1 || echo 'Perl not installed')" # Log Perl version
echo "PHP Version: $(php --version 2>&1 | head -n 1 || echo 'PHP not installed')" # Log PHP version
echo "MySQL Version: $(mysql --version 2>&1 || echo 'MySQL not installed')" # Log MySQL version
echo "PostgreSQL Version: $(psql --version 2>&1 || echo 'PostgreSQL not installed')" # Log PostgreSQL version       
echo "Git Version: $(git --version 2>&1 || echo 'Git not installed')" # Log Git version
echo "Docker Compose Version: $(docker-compose --version 2>&1 || echo 'Docker Compose not installed')" # Log Docker Compose version 
echo "Docker Version: $(docker --version 2>&1 || echo 'Docker not installed')" # Log Docker version 
echo "AWS CLI Version: $(aws --version 2>&1 || echo 'AWS CLI not installed')" # Log AWS CLI version
echo "Terraform Version: $(terraform --version 2>&1 | head -n 1 || echo 'Terraform not installed')" # Log Terraform version
echo "kubectl Version: $(kubectl version --client --short 2>&1 || echo 'kubectl not installed')" # Log kubectl version
echo "Helm Version: $(helm version --short 2>&1 || echo 'Helm not installed')" # Log Helm version
echo "Ansible Version: $(ansible --version 2>&1 | head -n 1 || echo 'Ansible not installed')" # Log Ansible version
echo "Software versions logged."
# ------------------------------
# 3. Finalization
# ------------------------------
echo "EC2 Bootstrap Completed: $(date)"  # End log entry
echo "Log file located at: $LOG_FILE" # Inform about log file location
echo "===== EC2 Bootstrap Ended: $(date) ====="     # End log entry             
# End of script
# ------------------------------
# 4. install essential packages
# ------------------------------
sudo apt-get install -y \   # Install essential packages
    curl \  #   curl for data transfer
    git \   #   git for version control 
    wget \  #   wget for file retrieval
    unzip \  #  unzip for extracting files
    vim \   #   vim text editor
    jq \   #   jq for JSON processing
    net-tools \  # net-tools for network management
    build-essential \   # build-essential for compiling software
    software-properties-common \  # software-properties-common for managing repositories
    apt-transport-https \   # apt-transport-https for HTTPS package retrieval
    ca-certificates \   # ca-certificates for SSL certificates
    gnupg \  #  gnupg for package signing
    htop \  # htop for system monitoring



# ------------------------------
# 5. Install Node.js & npm
# ------------------------------
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.19.0".

# Verify npm version:
npm -v # Should print "10.9.3".

# ------------------------------

# 6. MongoDB Installation

# ------------------------------

# Detect the latest on-prem MongoDB version
MONGO_VERSION="8.0"

# Detect Ubuntu codename dynamically
UBUNTU_CODENAME=$(lsb_release -sc)

# Define GPG keyring and sources list paths
KEYRING_PATH="/usr/share/keyrings/mongodb-server-${MONGO_VERSION}.gpg"
LIST_PATH="/etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list"

echo "[INFO] Updating package list and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y gnupg curl ca-certificates lsb-release

echo "[INFO] Adding MongoDB GPG key..."
curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc" | \
    sudo gpg --dearmor -o "${KEYRING_PATH}"

echo "[INFO] Setting up MongoDB repository for Ubuntu ${UBUNTU_CODENAME}..."
echo "deb [ arch=amd64,arm64 signed-by=${KEYRING_PATH} ] https://repo.mongodb.org/apt/ubuntu ${UBUNTU_CODENAME}/mongodb-org/${MONGO_VERSION} multiverse" | \
    sudo tee "${LIST_PATH}"

echo "[INFO] Updating package list again..."
sudo apt-get update -y

echo "[INFO] Installing mongodb-org (latest patch of ${MONGO_VERSION} series)..."
sudo apt-get install -y mongodb-org

echo "[INFO] Setting proper permissions for data directory..."
# Using default path; adjust if customized in mongod.conf
sudo mkdir -p /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo mkdir -p /var/log/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb

echo "[INFO] Enabling and starting MongoDB service..."
sudo systemctl daemon-reload
sudo systemctl enable --now mongod

echo "[INFO] MongoDB service status:"
sudo systemctl status mongod --no-pager

echo "[INFO] Installed MongoDB version:"
mongod --version

# ------------------------------
# 7. Git clone repos
# ------------------------------
INPUT_FILE="repos.txt"
LOG_FILE="./git-batch-clone.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Git Batch Cloning Script Started: $(date) ====="

# Validate input file
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "[ERROR] Input file '$INPUT_FILE' not found!"
  exit 1
fi

# Read each line: repo_url + target_dir
while read -r repo_url directory; do
  # Skip empty lines or comments
  [[ -z "$repo_url" || "$repo_url" =~ ^# ]] && continue

  # Validate repo URL
  if [[ ! "$repo_url" =~ ^(git@|https://) ]]; then
    echo "[ERROR] Invalid repo URL format: $repo_url"
    continue
  fi

  # Check for directory
  if [[ -z "$directory" ]]; then
    echo "[ERROR] No directory name provided for $repo_url"
    continue
  fi

  # Skip if directory exists
  if [[ -d "$directory" ]]; then
    echo "[WARNING] Directory '$directory' already exists. Skipping..."
    continue
  fi

  # Clone repo
  echo ">>> Cloning $repo_url into $directory ..."
  if git clone "$repo_url" "$directory"; then
    echo "[OK] Successfully cloned into $directory"
  else
    echo "[ERROR] Failed to clone $repo_url"
  fi

  echo "-------------------------------------"
done < "$INPUT_FILE"

echo "===== Script Finished: $(date) ====="
