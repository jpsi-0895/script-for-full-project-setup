#!/bin/bash

# ================================
# GitHub Project Setup Script
# ================================

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
cd "$TARGET_DIR" || exit

# Show package.json (first time)
if [[ -f "package.json" ]]; then
    echo "📦 package.json contents:"
    cat package.json
else
    echo "⚠️ No package.json found."
fi

# Run npm install
npm i
echo "✅ Repo cloned and npm packages installed in $(pwd)"

# Create .env file
ENV_FILE=".env"
echo "Creating $ENV_FILE ..."
: > "$ENV_FILE"

# Ask user for environment variables (multi-line paste support)
echo "Paste your environment variables (key=value). End with 'done' on a new line:"

while IFS= read -r line; do
    [[ "$line" == "done" ]] && break

    # Skip empty lines or comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" == *"="* ]]; then
        # Clean backticks + trim spaces
        clean_line=$(echo "$line" | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
        echo "$clean_line" >> "$ENV_FILE"
    else
        echo "⚠️ Invalid format. Use key=value"
    fi
done

echo "✅ .env file created with your variables:"
cat "$ENV_FILE"

# ================================
# Check package.json and ask before running
# ================================
if [[ -f "package.json" ]]; then
    echo ""
    echo "📦 Checking available npm scripts in package.json..."
    AVAILABLE_SCRIPTS=$(jq -r '.scripts | keys[]' package.json 2>/dev/null)

    for script in $AVAILABLE_SCRIPTS; do
        read -p "Do you want to run 'npm run $script'? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "🚀 Running npm run $script ..."
            npm run "$script"
        else
            echo "⏭️ Skipping npm run $script"
        fi
    done
else
    echo "⚠️ No package.json found, skipping script execution."
fi

# ================================
# Menu Loop for User Commands
# ================================
while true; do
    echo ""
    echo "Select an option:"
    echo "1) Run npm run start:prod"
    echo "2) Run npm run dev"
    echo "3) Run next dev -p 8000 -H 0.0.0.0"
    echo "4) Exit"
    read -p "Enter your choice [1-4]: " choice

    case $choice in
        1)
            if grep -q '"start:prod"' package.json; then
                echo "🚀 Running npm run start:prod ..."
                npm run start:prod
            else
                echo "⚠️ 'start:prod' not defined in package.json"
            fi
            ;;
        2)
            if grep -q '"dev"' package.json; then
                echo "🚀 Running npm run dev ..."
                npm run dev
            else
                echo "⚠️ 'dev' not defined in package.json"
            fi
            ;;
        3)
            echo "🚀 Running next dev -p 8000 -H 0.0.0.0 ..."
            npx next dev -p 8000 -H 0.0.0.0
            ;;
        4)
            echo "👋 Exiting script."
            break
            ;;
        *)
            echo "⚠️ Invalid choice. Please try again."
            ;;
    esac
done
