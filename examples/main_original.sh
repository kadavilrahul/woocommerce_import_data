#!/bin/bash

# WooCommerce Data Import Tools - Simple Menu
# Main script to run all Python tools

set -e

# Function to check if Python is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is not installed."
        exit 1
    fi
}

# Function to check if required files exist
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

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    python3 -m pip install -r requirements.txt
}

# Function to run product titles importer
run_product_titles() {
    print_section "Product Titles Importer"
    echo -e "${GREEN}This tool fetches only product titles from your WooCommerce store.${NC}"
    echo -e "${GREEN}Output: Lightweight CSV file with product titles only.${NC}"
    echo -e "${GREEN}Best for: Quick product catalog overview.${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Use default website (from config)"
    echo -e "${WHITE}2.${NC} Select Silk Road Emart"
    echo -e "${WHITE}3.${NC} Select Nilgiri Stores"
    echo -e "${WHITE}4.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-4): " choice
    
    case $choice in
        1)
            cd fetch_product_titles
            python3 main.py
            cd ..
            ;;
        2)
            cd fetch_product_titles
            python3 main.py --website silkroad
            cd ..
            ;;
        3)
            cd fetch_product_titles
            python3 main.py --website nilgiri
            cd ..
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
    echo -e "${GREEN}Product titles import completed!${NC}"
}

# Function to run full product data importer
run_product_data() {
    print_section "Full Product Data Importer"
    echo -e "${GREEN}This tool fetches comprehensive product information including:${NC}"
    echo -e "${GREEN}• Product Title${NC}"
    echo -e "${GREEN}• Price${NC}"
    echo -e "${GREEN}• Product Link${NC}"
    echo -e "${GREEN}• Category${NC}"
    echo -e "${GREEN}• Image URL${NC}"
    echo -e "${GREEN}Output: Detailed CSV file with complete product data.${NC}"
    echo -e "${GREEN}Best for: Complete product catalog with all details.${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Use default website (from config)"
    echo -e "${WHITE}2.${NC} Select Silk Road Emart"
    echo -e "${WHITE}3.${NC} Select Nilgiri Stores"
    echo -e "${WHITE}4.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-4): " choice
    
    case $choice in
        1)
            cd fetch_product_data
            python3 main.py
            cd ..
            ;;
        2)
            cd fetch_product_data
            python3 main.py --website silkroad
            cd ..
            ;;
        3)
            cd fetch_product_data
            python3 main.py --website nilgiri
            cd ..
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
    echo -e "${GREEN}Product data import completed!${NC}"
}

# Function to run order data importer (REST API)
run_order_data_api() {
    print_section "Order Data Importer (REST API Method)"
    echo -e "${GREEN}This tool fetches order information using WooCommerce REST API:${NC}"
    echo -e "${GREEN}• Customer Name${NC}"
    echo -e "${GREEN}• Email${NC}"
    echo -e "${GREEN}• Phone${NC}"
    echo -e "${GREEN}• Order ID${NC}"
    echo -e "${GREEN}• Order Status${NC}"
    echo -e "${GREEN}• Order Amount${NC}"
    echo -e "${GREEN}Output: CSV file with order data.${NC}"
    echo -e "${GREEN}Best for: Standard order data extraction via API.${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Use default website"
    echo -e "${WHITE}2.${NC} Interactive website selection"
    echo -e "${WHITE}3.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-3): " choice
    
    case $choice in
        1)
            python3 fetch_orders_api.py
            ;;
        2)
            python3 fetch_orders_api.py --interactive
            ;;
        3)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
    echo -e "${GREEN}Order data import (API method) completed!${NC}"
}

# Function to run order data importer (Database)
run_order_data_database() {
    print_section "Order Data Importer (Database Method)"
    echo -e "${GREEN}This tool fetches order information directly from MySQL database:${NC}"
    echo -e "${GREEN}• Enhanced performance for large datasets${NC}"
    echo -e "${GREEN}• Detailed order information including products${NC}"
    echo -e "${GREEN}• Support for date range filtering${NC}"
    echo -e "${GREEN}• Multiple database support${NC}"
    echo -e "${GREEN}Output: Comprehensive CSV file with order and product details.${NC}"
    echo -e "${GREEN}Best for: Large datasets, detailed analysis, better performance.${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Fetch all orders from Database 1"
    echo -e "${WHITE}2.${NC} Fetch all orders from Database 2"
    echo -e "${WHITE}3.${NC} Fetch orders from last 30 days (Database 1)"
    echo -e "${WHITE}4.${NC} Fetch orders from last 30 days (Database 2)"
    echo -e "${WHITE}5.${NC} Custom date range (Database 1)"
    echo -e "${WHITE}6.${NC} Custom date range (Database 2)"
    echo -e "${WHITE}7.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-7): " db_choice
    
    case $db_choice in
        1)
            python3 fetch_orders_database.py --db 1
            ;;
        2)
            python3 fetch_orders_database.py --db 2
            ;;
        3)
            python3 fetch_orders_database.py --db 1 --days 30
            ;;
        4)
            python3 fetch_orders_database.py --db 2 --days 30
            ;;
        5)
            read -p "Enter start date (YYYY-MM-DD): " start_date
            read -p "Enter end date (YYYY-MM-DD): " end_date
            python3 fetch_orders_database.py --db 1 --start "$start_date" --end "$end_date"
            ;;
        6)
            read -p "Enter start date (YYYY-MM-DD): " start_date
            read -p "Enter end date (YYYY-MM-DD): " end_date
            python3 fetch_orders_database.py --db 2 --start "$start_date" --end "$end_date"
            ;;
        7)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
    echo -e "${GREEN}Order data import (Database method) completed!${NC}"
}

# Function to run WordPress activity monitoring
run_activity_monitoring() {
    print_section "WordPress Activity Monitoring"
    echo -e "${GREEN}Monitor WordPress user activities and security events:${NC}"
    echo -e "${GREEN}• User login/logout activities${NC}"
    echo -e "${GREEN}• Content changes and updates${NC}"
    echo -e "${GREEN}• Security audit log integration${NC}"
    echo -e "${GREEN}• Multi-domain support${NC}"
    echo -e "${GREEN}Output: Real-time activity display and optional CSV export.${NC}"
    echo -e "${GREEN}Best for: Security monitoring, user activity tracking.${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Monitor Domain 1 activities (last 10 events)"
    echo -e "${WHITE}2.${NC} Monitor Domain 2 activities (last 10 events)"
    echo -e "${WHITE}3.${NC} Run diagnostics for Domain 1"
    echo -e "${WHITE}4.${NC} Run diagnostics for Domain 2"
    echo -e "${WHITE}5.${NC} Custom activity limit for Domain 1"
    echo -e "${WHITE}6.${NC} Custom activity limit for Domain 2"
    echo -e "${WHITE}7.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-7): " activity_choice
    
    case $activity_choice in
        1)
            python3 monitor_activity_domain1.py --limit 10
            ;;
        2)
            python3 monitor_activity_domain2.py --limit 10
            ;;
        3)
            python3 monitor_activity_domain1.py --diagnose
            ;;
        4)
            python3 monitor_activity_domain2.py --diagnose
            ;;
        5)
            read -p "Enter number of activities to display: " limit
            python3 monitor_activity_domain1.py --limit "$limit"
            ;;
        6)
            read -p "Enter number of activities to display: " limit
            python3 monitor_activity_domain2.py --limit "$limit"
            ;;
        7)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
    echo -e "${GREEN}Activity monitoring completed!${NC}"
}

# Function to test AI integration
run_ai_test() {
    print_section "AI Integration Test"
    echo -e "${GREEN}Test Google Gemini AI integration:${NC}"
    echo -e "${GREEN}• Verify API connectivity${NC}"
    echo -e "${GREEN}• Test AI response capabilities${NC}"
    echo -e "${GREEN}• Validate configuration${NC}"
    echo -e "${GREEN}Output: AI response and connection status.${NC}"
    echo -e "${GREEN}Best for: Testing AI features before using in production.${NC}"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    python3 test_ai_integration.py
    echo -e "${GREEN}AI integration test completed!${NC}"
}

# Function to run maintenance tools
run_maintenance() {
    print_section "Maintenance Tools"
    echo -e "${GREEN}Various maintenance and utility tools:${NC}"
    echo ""
    echo -e "${YELLOW}Available options:${NC}"
    echo -e "${WHITE}1.${NC} Reset order data import progress (REST API)"
    echo -e "${WHITE}2.${NC} Reset product data import progress"
    echo -e "${WHITE}3.${NC} Reset product titles import progress"
    echo -e "${WHITE}4.${NC} Generate project information report"
    echo -e "${WHITE}5.${NC} Back to main menu"
    echo ""
    
    read -p "Select an option (1-5): " maintenance_choice
    
    case $maintenance_choice in
        1)
            echo "Resetting order data import progress..."
            rm -f current_page_*.txt order_data_*.csv
            echo -e "${GREEN}Order data import progress reset!${NC}"
            ;;
        2)
            cd fetch_product_data
            python3 reset_script.py
            cd ..
            echo -e "${GREEN}Product data import progress reset!${NC}"
            ;;
        3)
            cd fetch_product_titles
            python3 reset_script.py
            cd ..
            echo -e "${GREEN}Product titles import progress reset!${NC}"
            ;;
        4)
            bash tools/generate_project_report.sh
            echo -e "${GREEN}Project information report generated!${NC}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Returning to main menu.${NC}"
            return
            ;;
    esac
}

# Function to show configuration help
show_config_help() {
    print_section "Configuration Help"
    echo -e "${GREEN}This tool supports multiple configuration methods:${NC}"
    echo ""
    echo -e "${YELLOW}1. Environment Variables (.env file):${NC}"
    echo -e "${WHITE}   • Copy sample.env to .env${NC}"
    echo -e "${WHITE}   • Update with your credentials${NC}"
    echo -e "${WHITE}   • Supports multiple databases and domains${NC}"
    echo ""
    echo -e "${YELLOW}2. JSON Configuration (config.json):${NC}"
    echo -e "${WHITE}   • Copy sample_config.json to config.json${NC}"
    echo -e "${WHITE}   • Update with your WooCommerce API credentials${NC}"
    echo -e "${WHITE}   • Used for REST API methods${NC}"
    echo ""
    echo -e "${YELLOW}Required Credentials:${NC}"
    echo -e "${WHITE}   • WooCommerce Consumer Key and Secret${NC}"
    echo -e "${WHITE}   • Site URL${NC}"
    echo -e "${WHITE}   • Database credentials (for database methods)${NC}"
    echo -e "${WHITE}   • Gemini API key (optional, for AI features)${NC}"
    echo ""
    echo -e "${YELLOW}Files to configure:${NC}"
    if [ -f "sample.env" ]; then
        echo -e "${GREEN}   ✓ sample.env found${NC}"
    else
        echo -e "${RED}   ✗ sample.env not found${NC}"
    fi
    
    if [ -f "sample_config.json" ]; then
        echo -e "${GREEN}   ✓ sample_config.json found${NC}"
    else
        echo -e "${RED}   ✗ sample_config.json not found${NC}"
    fi
    
    if [ -f ".env" ]; then
        echo -e "${GREEN}   ✓ .env configured${NC}"
    else
        echo -e "${YELLOW}   ! .env not found (copy from sample.env)${NC}"
    fi
    
    if [ -f "config.json" ]; then
        echo -e "${GREEN}   ✓ config.json configured${NC}"
    else
        echo -e "${YELLOW}   ! config.json not found (copy from sample_config.json)${NC}"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Main menu function
show_main_menu() {
    clear
    print_header "WooCommerce Data Import Tools - Interactive Menu"
    
    echo -e "${WHITE}Welcome to the WooCommerce Data Import Tools!${NC}"
    echo -e "${WHITE}This comprehensive toolkit helps you extract and monitor data from WooCommerce stores.${NC}"
    echo ""
    
    print_section "Data Import Tools"
    print_option "1." "Product Titles Importer"
    print_description "Lightweight tool to fetch only product titles"
    
    print_option "2." "Full Product Data Importer"
    print_description "Comprehensive product information extraction (title, price, category, images)"
    
    print_option "3." "Order Data Importer (REST API)"
    print_description "Standard WooCommerce API method for order data extraction"
    
    print_option "4." "Order Data Importer (Database)"
    print_description "Direct MySQL access for enhanced performance and detailed data"
    
    print_section "Monitoring & Analysis Tools"
    print_option "5." "WordPress Activity Monitoring"
    print_description "Monitor user activities and security events across domains"
    
    print_option "6." "AI Integration Test"
    print_description "Test Google Gemini AI connectivity and capabilities"
    
    print_section "Maintenance & Utilities"
    print_option "7." "Maintenance Tools"
    print_description "Reset progress, generate reports, and other utilities"
    
    print_option "8." "Configuration Help"
    print_description "Help with setting up credentials and configuration files"
    
    print_option "9." "Install Dependencies"
    print_description "Install required Python packages"
    
    print_section "System Options"
    print_option "0." "Exit"
    print_description "Exit the application"
    
    echo ""
    echo -e "${BLUE}================================================================================================${NC}"
}

# Main execution function
main() {
    # Check prerequisites
    check_python
    check_requirements
    
    while true; do
        show_main_menu
        read -p "$(echo -e ${YELLOW}Please select an option [0-9]: ${NC})" choice
        
        case $choice in
            1)
                run_product_titles
                read -p "Press Enter to continue..."
                ;;
            2)
                run_product_data
                read -p "Press Enter to continue..."
                ;;
            3)
                run_order_data_api
                read -p "Press Enter to continue..."
                ;;
            4)
                run_order_data_database
                read -p "Press Enter to continue..."
                ;;
            5)
                run_activity_monitoring
                read -p "Press Enter to continue..."
                ;;
            6)
                run_ai_test
                read -p "Press Enter to continue..."
                ;;
            7)
                run_maintenance
                read -p "Press Enter to continue..."
                ;;
            8)
                show_config_help
                ;;
            9)
                install_dependencies
                read -p "Press Enter to continue..."
                ;;
            0)
                echo -e "${GREEN}Thank you for using WooCommerce Data Import Tools!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select a number between 0-9.${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run the main function
main