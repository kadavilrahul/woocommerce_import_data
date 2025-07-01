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
    echo "WARNING: This will delete ALL temporary files including:"
    echo "- Python cache (__pycache__)"
    echo "- Node.js modules (node_modules)"
    echo "- Virtual environment (venv)"
    echo "- Temporary files (*.log, *.pid, tmp_code_*.bash)"
    echo "- Node.js package files (package-lock.json, package.json)"
    read -p "Are you sure you want to clean all? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "Cleaning all temporary files..."
        rm -rf __pycache__ node_modules venv
        rm -f tmp_code_*.bash *.log *.pid package-lock.json package.json
        echo "All temporary files cleaned (config files preserved)"
    else
        echo "Cleanup cancelled"
    fi
}

# Setup Python virtual environment and dependencies
setup_python_env() {
    echo "Setting up Python environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip > /dev/null 2>&1
    
    # Install requirements
    echo "Installing Python dependencies..."
    pip install -r requirements.txt > /dev/null 2>&1
    
    echo "Python environment ready!"
}

# Run Python script with virtual environment
run_python_with_venv() {
    local script_name="$1"
    shift  # Remove first argument, keep the rest as script arguments
    
    # Setup environment if needed
    if [ ! -d "venv" ] || ! source venv/bin/activate 2>/dev/null; then
        setup_python_env
    else
        source venv/bin/activate
    fi
    
    # Run the script
    python3 "$script_name" "$@"
    
    # Deactivate virtual environment
    deactivate 2>/dev/null || true
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
    echo "9. Command Reference - Show useful commands"
    echo "10. Reset Data Files"
    echo "0. Exit"
    echo ""
}

# Product data submenu
product_data_menu() {
    echo "Product Data Import"
    echo "=================="
    echo "1. Python implementation"
    echo "2. Node.js implementation"
    echo "3. Back to main menu"
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
    echo "3. Back to main menu"
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
    echo "3. Back to main menu"
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
        read -p "Select option [0-9]: " choice
        
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
                # Load .env file if exists
                if [ -f ".env" ]; then
                    set -a
                    source .env
                    set +a
                fi
                
                echo "Select domain to monitor:"
                domain1=${DOMAIN_1:-"Domain 1"}
                domain2=${DOMAIN_2:-"Domain 2"}
                echo "1. $domain1"
                echo "2. $domain2"
                read -p "Select domain [1-2]: " domain_num
                
                # Generate timestamped CSV filename
                csv_file="activity_log_$(date +%Y%m%d_%H%M%S).csv"
                
                read -p "Enter number of entries to show [default: 5]: " limit
                limit=${limit:-5}  # Default to 5 if empty
                
                echo "Running activity monitor for recent entries..."
                run_python_with_venv monitor_activity.py --domain "$domain_num" --limit "$limit" --csv "$csv_file"
                if [ -s "$csv_file" ]; then
                    echo "Activity log saved with data: $csv_file"
                else
                    echo "No recent activity records found - empty log created: $csv_file"
                fi
                read -p "Press Enter to continue..."
                ;;
            5)
               echo "Dependency Installation"
               echo "======================="
               echo "1. Install Python dependencies"
               echo "2. Install Node.js dependencies"
               echo "3. Install both"
               echo "4. Back to main menu"
               read -p "Select option [1-4]: " dep_choice
               
               case $dep_choice in
                   1)
                       echo "Setting up Python virtual environment..."
                       setup_python_env
                       echo "✓ Python dependencies installed"
                       show_command_reference
                       ;;
                   2)
                       if check_nodejs; then
                           echo "Installing Node.js dependencies..."
                           setup_nodejs_deps
                           echo "✓ Node.js dependencies installed"
                           show_command_reference
                       else
                           echo "Node.js not available - skipping"
                       fi
                       ;;
                   3)
                       echo "Setting up Python virtual environment..."
                       setup_python_env
                       if check_nodejs; then
                           echo "Installing Node.js dependencies..."
                           setup_nodejs_deps
                           echo "✓ All dependencies installed"
                           show_command_reference
                       else
                           echo "Node.js not available - installed Python only"
                       fi
                       ;;
                   4)
                       ;;
                   *)
                       echo "Invalid option"
                       ;;
               esac
               read -p "Press Enter to continue..."
                ;;
            6)
               echo "Configuration Check:"
               echo "==================="
               
               # Initialize status
               all_ok=true
               
               # Check .env file
               if [ -f ".env" ] && [ -s ".env" ]; then
                   echo "✓ .env"
               else
                   echo "✗ .env"
                   all_ok=false
               fi
               
               # Check config.json file
               if [ -f "config.json" ] && jq empty config.json >/dev/null 2>&1; then
                   echo "✓ config.json"
               else
                   echo "✗ config.json"
                   all_ok=false
               fi
               
               # Show overall status
               if $all_ok; then
                   echo "✓✓ All configurations OK ✓✓"
               else
                   echo "✗ Some configurations missing/invalid"
               fi
               
               echo "==================="
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
            10)
                echo "Resetting data files..."
                rm -f data/product_*.csv data/product_*.txt
                echo "All product data files removed from /data directory"
                read -p "Press Enter to continue..."
                ;;
           10)
               echo "Invalid option. Please select 0-9."
               read -p "Press Enter to continue..."
               ;;
       esac
   done
}

# Show command reference
show_command_reference() {
   clear
   echo "Command Reference"
   echo "================"
   echo ""
   echo "Python Virtual Environment:"
   echo "--------------------------"
   echo "1. Create virtual environment: python3 -m venv venv"
   echo "2. Activate virtual environment: source venv/bin/activate"
   echo "3. Deactivate virtual environment: deactivate"
   echo "4. Install requirements: pip install -r requirements.txt"
   echo ""
   echo "Node.js:"
   echo "--------"
   echo "1. Initialize project: npm init -y"
   echo "2. Install dependencies: npm install @woocommerce/woocommerce-rest-api"
   echo "3. Run script: node script.js"
   echo ""
   echo "Press Enter to return to menu..."
   read
}

# Run main function
main
