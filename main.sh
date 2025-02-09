#!/bin/bash

echo "🔧 WooCommerce Product Title Import Setup"
echo "=======================================\n"

# Function to create config.json
create_config() {
    echo "📝 Please enter your WooCommerce credentials:"
    echo "-------------------------------------------"
    
    # Get user input
    read -p "Enter Consumer Key (e.g., ck_xxxx): " consumer_key
    read -p "Enter Consumer Secret (e.g., cs_xxxx): " consumer_secret
    read -p "Enter Site URL (e.g., https://example.com): " site_url

    # Remove trailing slash from URL if present
    site_url=${site_url%/}

    # Create config.json
    echo "Creating config.json..."
    cat > config.json << EOF
{
    "CONSUMER_KEY": "${consumer_key}",
    "CONSUMER_SECRET": "${consumer_secret}",
    "SITE_URL": "${site_url}"
}
EOF

    echo "✅ config.json created successfully!"
}

# Function to check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed. Please install Node.js to use the Node.js script."
        return 1
    fi
    return 0
}

# Function to check if Python is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3 is not installed. Please install Python 3 to use the Python script."
        return 1
    fi
    return 0
}

# Function to setup Node.js dependencies
setup_nodejs() {
    echo "📦 Setting up Node.js dependencies..."
    if [ ! -f "package.json" ]; then
        npm init -y > /dev/null 2>&1
    fi
    npm install @woocommerce/woocommerce-rest-api --silent
    echo "✅ Node.js dependencies installed!"
}

# Main script
echo "First, let's set up your configuration."
create_config

echo -e "\n🚀 Choose which script to run:"
echo "1) Python script"
echo "2) Node.js script"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        if check_python; then
            echo -e "\n🐍 Running Python script..."
            python3 main.py
        fi
        ;;
    2)
        if check_nodejs; then
            setup_nodejs
            echo -e "\n🟨 Running Node.js script..."
            node main.js
        fi
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again and select 1 or 2."
        exit 1
        ;;
esac
