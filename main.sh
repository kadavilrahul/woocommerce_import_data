#!/bin/bash

# WooCommerce Data Import Tools - Enhanced Menu
# Main script to run all tools with multiple language support

set -e

# Check if Python is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is not installed."
        exit 1
    fi
}

# Check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "Error: Node.js is not installed."
        return 1
    fi
    return 0
}

# Setup Node.js dependencies for product titles
setup_nodejs_deps() {
    echo "Setting up Node.js dependencies..."
    if [ ! -f "package.json" ]; then
        npm init -y > /dev/null 2>&1
    fi
    npm install @woocommerce/woocommerce-rest-api --silent
    echo "Node.js dependencies installed!"
}

# Cleanup function for temporary files
cleanup_env_files() {
    echo "Cleaning up temporary files..."
    echo "Select cleanup option:"
    echo "1. Clean cache files (__pycache__, node_modules)"
    echo "2. Clean all temporary files (cache + venv + tmp files)"
    echo "3. Cancel"
    read -p "Select option [1-3]: " cleanup_choice
    
    case $cleanup_choice in
        1)
            echo "WARNING: This will delete cache files"
            read -p "Are you sure you want to continue? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo "Cleaning cache files..."
                rm -rf __pycache__ node_modules
                rm -f tmp_code_*.bash
                echo "Cache files cleaned (config files preserved)"
            else
                echo "Cleanup cancelled"
            fi
            ;;
        2)
            echo "WARNING: This will delete ALL temporary files including virtual environment"
            read -p "Are you sure you want to continue? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo "Cleaning all temporary files..."
                rm -rf __pycache__ node_modules venv
                rm -f tmp_code_*.bash *.log *.pid
                echo "All temporary files cleaned (config files preserved)"
            else
                echo "Cleanup cancelled"
            fi
            ;;
        3)
            echo "Cleanup cancelled"
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Check if required files exist
check_requirements() {
    if [ ! -f "requirements.txt" ]; then
        echo "Error: requirements.txt not found."
        exit 1
    fi
    
    if [ ! -f ".env" ] && [ ! -f "config.json" ]; then
        echo "Warning: No configuration found. Copy sample.env to .env or sample_config.json to config.json"
        read -p "Continue anyway? (y/N): " continue_anyway
        if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Website selection function
select_website() {
    if [ ! -f "config.json" ]; then
        echo "Error: config.json not found. Using default configuration."
        return
    fi
    
    echo ""
    echo "Available Websites:"
    echo "=================="
    
    # Show website options using Python
    python3 -c "
import json
try:
    with open('config.json', 'r') as f:
        config = json.load(f)
    websites = list(config.get('websites', {}).keys())
    for i, website in enumerate(websites, 1):
        site_config = config['websites'][website]
        print(f'{i}. {website}')
        print(f'   URL: {site_config.get(\"SITE_URL\", \"Unknown\")}')
        print(f'   Domain: {site_config.get(\"DOMAIN\", \"Unknown\")}')
        print()
except Exception as e:
    print('Error reading config.json:', e)
    exit(1)
"
    
    echo "0. Use default website"
    echo ""
    
    # Get website names for selection
    websites=($(python3 -c "
import json
try:
    with open('config.json', 'r') as f:
        config = json.load(f)
    websites = list(config.get('websites', {}).keys())
    print(' '.join(websites))
except:
    pass
"))
    
    if [ ${#websites[@]} -eq 0 ]; then
        echo "Error: No websites found in config.json"
        return
    fi
    
    while true; do
        read -p "Select website [0-${#websites[@]}]: " choice
        
        if [[ "$choice" == "0" ]]; then
            SELECTED_WEBSITE=""
            echo "Selected: Using default website"
            break
        elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -le "${#websites[@]}" ]; then
            SELECTED_WEBSITE="${websites[$((choice-1))]}"
            echo "Selected website: $SELECTED_WEBSITE"
            break
        else
            echo "Invalid choice. Please select 0-${#websites[@]}"
        fi
    done
}

# Show menu
show_menu() {
    clear
    echo "WooCommerce Data Import Tools"
    echo "============================="
    echo "1. Product Titles - Choose Python or Node.js"
    echo "2. Product Data - Choose Python or Node.js"
    echo "3. Orders - Choose API or Database"
    echo "4. Activity Monitor - Monitor WordPress activities"
    echo "5. Install Dependencies - Install required packages"
    echo "6. Config Test - Test configuration settings"
    echo "7. Cleanup - Clean environment and data files"
    echo "8. Generate Project Report"
    echo "0. Exit"
    echo ""
}

# Product data submenu
product_data_menu() {
    echo "Product Data Import"
    echo "=================="
    echo "1. Python implementation"
    echo "2. Node.js implementation"
    echo "3. Reset/Clean product data"
    echo "4. Back to main menu"
    read -p "Select option [1-4]: " pd_choice
    
    case $pd_choice in
        1)
            select_website
            echo "Running Product Data Importer (Python)..."
            if [ -n "$SELECTED_WEBSITE" ]; then
                python3 fetch_product_data_main_generic.py --website "$SELECTED_WEBSITE"
            else
                python3 fetch_product_data_main.py
            fi
            ;;
        2)
            if check_nodejs; then
                setup_nodejs_deps
                select_website
                echo "Running Product Data Importer (Node.js)..."
                if [ -f "config.json" ] && grep -q '"websites"' config.json && grep -q '"default_website"' config.json; then
                    if [ -n "$SELECTED_WEBSITE" ]; then
                        node fetch_product_data_main_enhanced.js --website "$SELECTED_WEBSITE"
                    else
                        node fetch_product_data_main_enhanced.js
                    fi
                else
                    echo "Error: Invalid config.json structure"
                    echo "Please ensure config.json has websites and default_website defined"
                fi
            else
                echo "Node.js not available. Please install Node.js or use Python option."
            fi
            ;;
        3)
            echo "Resetting product data..."
            python3 -c "from fetch_product_data_reset import reset_script; reset_script()"
            ;;
        4)
            return
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Orders submenu
orders_menu() {
    echo "Orders Import"
    echo "============="
    echo "1. API - Fetch orders via WooCommerce API"
    echo "2. Database - Fetch orders from database"
    echo "3. Reset/Clean order data"
    echo "4. Back to main menu"
    read -p "Select option [1-4]: " order_choice
    
    case $order_choice in
        1)
            echo "Running Order Data Importer (API)..."
            python3 fetch_orders_api_generic.py --interactive
            ;;
        2)
            echo "Running Order Data Importer (Database)..."
            # Setup virtual environment if needed
            if [ ! -d "venv" ]; then
                python3 -m venv venv
                source venv/bin/activate
                pip install -r requirements.txt
            elif [ -z "$VIRTUAL_ENV" ]; then
                source venv/bin/activate
            fi
            
            # Ensure mysql-connector is installed
            if ! python3 -c "import mysql.connector" &>/dev/null; then
                pip install mysql-connector-python
            fi
            
            python3 fetch_orders_database.py
            ;;
        3)
            echo "Resetting order data..."
            python3 -c "from fetch_orders_reset import reset_script; reset_script()"
            ;;
        4)
            return
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Product titles submenu
product_titles_menu() {
    echo "Product Titles Import"
    echo "===================="
    echo "1. Python implementation"
    echo "2. Node.js implementation"
    echo "3. Reset/Clean product titles data"
    echo "4. Back to main menu"
    read -p "Select option [1-4]: " pt_choice
    
    case $pt_choice in
        1)
            select_website
            echo "Running Product Titles Importer (Python)..."
            if [ -n "$SELECTED_WEBSITE" ]; then
                python3 fetch_product_titles_main_generic.py --website "$SELECTED_WEBSITE"
            else
                python3 fetch_product_titles_main.py
            fi
            ;;
        2)
            if check_nodejs; then
                setup_nodejs_deps
                select_website
                echo "Running Product Titles Importer (Node.js)..."
                if [ -f "config.json" ] && grep -q '"websites"' config.json && grep -q '"default_website"' config.json; then
                    if [ -n "$SELECTED_WEBSITE" ]; then
                        node fetch_product_titles_main_enhanced.js --website "$SELECTED_WEBSITE"
                    else
                        node fetch_product_titles_main.js
                    fi
                else
                    echo "Error: Invalid config.json structure"
                    echo "Please ensure config.json has websites and default_website defined"
                fi
            else
                echo "Node.js not available. Please install Node.js or use Python option."
            fi
            ;;
        3)
            echo "Resetting product titles data..."
            python3 -c "from fetch_product_titles_reset import reset_script; reset_script()"
            ;;
        4)
            return
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Main execution
main() {
    check_python
    check_requirements
    
    while true; do
        show_menu
        read -p "Select option [0-8]: " choice
        
        case $choice in
            1)
                product_titles_menu
                read -p "Press Enter to continue..."
                ;;
            2)
                product_data_menu
                read -p "Press Enter to continue..."
                ;;
            3)
                orders_menu
                read -p "Press Enter to continue..."
                ;;
            4)
                echo "Running Activity Monitor..."
                echo "1. Domain 1"
                echo "2. Domain 2"
                read -p "Select domain [1-2]: " domain
                case $domain in
                    1) python3 monitor_activity_domain1.py ;;
                    2) python3 monitor_activity_domain2.py ;;
                    *) echo "Invalid domain" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            5)
                echo "Installing dependencies..."
                python3 -m pip install -r requirements.txt
                read -p "Press Enter to continue..."
                ;;
            6)
                echo "Configuration Test..."
                python3 -c "
from dotenv import load_dotenv
import os
load_dotenv()
print('Testing configuration...')
print(f'Site URL: {os.getenv(\"SITE_URL\", \"Not configured\")}')
print(f'Consumer Key: {os.getenv(\"CONSUMER_KEY\", \"Not configured\")[:10] + \"...\" if os.getenv(\"CONSUMER_KEY\") else \"Not configured\"}')
print(f'Database: {os.getenv(\"DATABASE_NAME_1\", \"Not configured\")}')
"
                read -p "Press Enter to continue..."
                ;;
            7)
                cleanup_env_files
                read -p "Press Enter to continue..."
                ;;
            8)
                echo "Generating project report..."
                ./generate_project_report.sh
                read -p "Press Enter to continue..."
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please select 0-8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run main function
main