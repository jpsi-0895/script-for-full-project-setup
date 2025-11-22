#!/bin/bash
set -euo pipefail

# ===========================
# MySQL Setup Automation Script
# ===========================

DB_NAME="blastrooms"
SQL_FILE="blastrooms.sql"
NEW_USER="ajpdas"
NEW_PASS="alKyrtE5007sd!"

echo "=== Logging into MySQL as root ==="
sudo mysql <<EOF
-- Create database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- List databases
SHOW DATABASES;

-- Switch to new database
USE ${DB_NAME};
SHOW TABLES;

-- Switch to mysql internal DB
USE mysql;

-- Create user (skip if exists)
CREATE USER IF NOT EXISTS '${NEW_USER}'@'%' IDENTIFIED BY '${NEW_PASS}';

-- Grant privileges
GRANT ALL PRIVILEGES ON *.* TO '${NEW_USER}'@'%' WITH GRANT OPTION;

-- Apply changes
FLUSH PRIVILEGES;
EOF

echo "=== Importing SQL file into ${DB_NAME} ==="
if [ -f "${SQL_FILE}" ]; then
    sudo mysql ${DB_NAME} < ${SQL_FILE}
else
    echo "⚠️ SQL file ${SQL_FILE} not found! Skipping import"
fi

echo "=== Testing login with new user ==="
mysql -u ${NEW_USER} -p${NEW_PASS} -e "SHOW DATABASES;"

echo "=== DONE ==="
