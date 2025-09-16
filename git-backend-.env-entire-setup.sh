#!/bin/bash

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

# Show package.json (before build/start)
if [[ -f "package.json" ]]; then
    echo "📦 package.json contents before build/start:"
    cat package.json
else
    echo "⚠️ No package.json found, skipping build/start."
    exit 1
fi

# Run npm build
if npm run build; then
    echo "🎉 Build completed successfully!"
else
    echo "❌ Build failed. Check errors above."
    exit 1
fi

# Run npm start:prod
if npm run start:prod; then
    echo "🚀 Application started in production mode!"
else
    echo "❌ Failed to start application with 'npm run start:prod'."
    exit 1
fi
