#!/usr/bin/env python3
"""
Enhanced Order Data Fetcher with Multi-Website Support
Supports both JSON config and environment variables for multiple websites
"""

import requests
import time
import json
import csv
import os
import sys
import argparse
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def get_current_page(website_name="default"):
    """Retrieve the current page from the property file."""
    page_file = f"data/current_page_{website_name}.txt"
    try:
        with open(page_file, "r") as file:
            return int(file.read().strip())
    except FileNotFoundError:
        return 1
    except ValueError:
        print("⚠️ Warning: Invalid page number in current_page.txt. Starting from page 1.")
        return 1

def save_current_page(page, website_name="default"):
    """Save the current page number to the property file."""
    page_file = f"data/current_page_{website_name}.txt"
    try:
        with open(page_file, "w") as file:
            file.write(str(page))
    except IOError as e:
        print(f"⚠️ Warning: Could not save current page: {e}")

def extract_order_data(order):
    """Extract required data fields from an order."""
    try:
        return {
            "name": f"{order['billing']['first_name']} {order['billing']['last_name']}".strip(),
            "email": order['billing']['email'],
            "phone": order['billing']['phone'],
            "order_id": order['id'],
            "order_status": order['status'],
            "order_amount": order['total']
        }
    except KeyError as e:
        print(f"⚠️ Warning: Could not extract field {e} from order {order.get('id', 'unknown')}")
        return None

def fetch_orders(page, config):
    """Fetch order data from WooCommerce API."""
    api_url = f"{config['SITE_URL']}/wp-json/wc/v3/orders"
    params = {
        'page': page,
        'per_page': 50,
        'consumer_key': config['CONSUMER_KEY'],
        'consumer_secret': config['CONSUMER_SECRET']
    }
    
    try:
        response = requests.get(api_url, params=params)
        response.raise_for_status()
        orders = response.json()
        
        order_data = []
        for order in orders:
            data = extract_order_data(order)
            if data:
                order_data.append(data)
        
        return order_data, len(orders) == 50
    except requests.RequestException as e:
        print(f"❌ Error fetching data from API: {e}")
        return [], False
    except (KeyError, json.JSONDecodeError) as e:
        print(f"❌ Error processing API response: {e}")
        return [], False

def write_orders_to_csv(orders, csv_file, website_name="default"):
    """Write order data to a CSV file."""
    try:
        # Ensure data directory exists
        os.makedirs(os.path.dirname(csv_file), exist_ok=True)
        # Open in append mode to add new orders
        mode = 'a' if get_current_page(website_name) > 1 else 'w'
        with open(csv_file, mode, newline='', encoding='utf-8') as f:
            writer = csv.writer(f, quoting=csv.QUOTE_ALL)
            # Write header if it's a new file
            if mode == 'w':
                writer.writerow(['Name', 'Email', 'Phone', 'Order ID', 'Order Status', 'Order Amount'])
            # Write order data
            for order in orders:
                writer.writerow([
                    order["name"],
                    order["email"],
                    order["phone"],
                    order["order_id"],
                    order["order_status"],
                    order["order_amount"]
                ])
        print(f"✓ Successfully wrote {len(orders)} orders to {csv_file}")
    except Exception as e:
        print(f"❌ Error writing to CSV file: {e}")

def fetch_woocommerce_orders(config, website_name="default"):
    """Main function to fetch order data and save them to CSV."""
    site_url = config['SITE_URL']
    domain = config.get('DOMAIN', 'unknown')
    csv_file = f"data/order_data_{website_name}.csv"
    
    print(f"\n🔄 Starting to fetch order data from {site_url}")
    print(f"📊 Website: {domain}")
    
    current_page = get_current_page(website_name)
    total_orders = 0

    while True:
        print(f"📥 Fetching page {current_page}...", end=' ', flush=True)
        orders, has_more = fetch_orders(current_page, config)
        
        if not orders:
            if current_page == 1:
                print("❌ No orders found or error occurred.")
                break
            print("✓ No more orders to fetch.")
            break

        total_orders += len(orders)
        write_orders_to_csv(orders, csv_file, website_name)
        save_current_page(current_page, website_name)

        if not has_more:
            print("✓ Reached the last page.")
            break

        current_page += 1
        time.sleep(1)  # Add delay to avoid hitting API rate limits

    print(f"\n✅ Finished! Total orders processed: {total_orders}")
    print(f"📁 Results saved to {csv_file}")

def get_website_config(website_name=None):
    """Get configuration for a website"""
    return {
        'CONSUMER_KEY': os.getenv('CONSUMER_KEY'),
        'CONSUMER_SECRET': os.getenv('CONSUMER_SECRET'),
        'SITE_URL': os.getenv('SITE_URL'),
        'DOMAIN': os.getenv('DOMAIN_1')
    }
    else:
        # Default configuration
        return {
            'CONSUMER_KEY': os.getenv('CONSUMER_KEY'),
            'CONSUMER_SECRET': os.getenv('CONSUMER_SECRET'),
            'SITE_URL': os.getenv('SITE_URL'),
            'DOMAIN': os.getenv('DOMAIN_1')
        }

def list_available_websites():
    """List available websites based on environment variables"""
    websites = []
    if os.getenv('CONSUMER_KEY'):
        websites.append('default')
    return websites

def select_website_interactive():
    """Interactive website selection"""
    websites = list_available_websites()
    
    if not websites:
        print("No websites found in configuration.")
        return None, None
    
    print("\nAvailable websites:")
    print("-" * 40)
    
    for i, website in enumerate(websites, 1):
        config = get_website_config(website if website != 'default' else None)
        site_url = config.get('SITE_URL', 'Unknown URL')
        domain = config.get('DOMAIN', 'Unknown Domain')
        print(f"{i}. {website}")
        print(f"   URL: {site_url}")
        print(f"   Domain: {domain}")
        print()
    
    while True:
        try:
            choice = input(f"Select website (1-{len(websites)}) or press Enter for default: ").strip()
            
            if not choice:
                selected = websites[0]
                print(f"Using default website: {selected}")
                break
            
            choice_num = int(choice)
            if 1 <= choice_num <= len(websites):
                selected = websites[choice_num - 1]
                print(f"Selected website: {selected}")
                break
            else:
                print(f"Please enter a number between 1 and {len(websites)}")
        
        except ValueError:
            print("Please enter a valid number")
        except KeyboardInterrupt:
            print("\nOperation cancelled")
            sys.exit(0)
    
    # Get configuration for selected website
    config = get_website_config(selected if selected != 'default' else None)
    return selected, config

def validate_config(config, required_keys):
    """Validate configuration has required keys"""
    missing = [key for key in required_keys if not config.get(key)]
    if missing:
        print(f"❌ Missing configuration: {', '.join(missing)}")
        return False
    return True

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Fetch WooCommerce orders with multi-website support')
    parser.add_argument('--website', type=str, help='Website name (from config.json)')
    parser.add_argument('--interactive', action='store_true', help='Interactive website selection')
    parser.add_argument('--list', action='store_true', help='List available websites')
    
    args = parser.parse_args()
    
    if args.list:
        websites = list_available_websites()
        if websites:
            print("Available websites:")
            for website in websites:
                print(f"  - {website}")
        else:
            print("No websites configured")
        return
    
    website_name = None
    config = None
    
    if args.interactive or not args.website:
        # Interactive selection
        website_name, config = select_website_interactive()
    else:
        # Use specified website
        website_name = args.website
        config = get_website_config(website_name if website_name != 'default' else None)
    
    if not config:
        print("❌ Failed to get configuration")
        sys.exit(1)
    
    # Validate configuration
    required_keys = ['CONSUMER_KEY', 'CONSUMER_SECRET', 'SITE_URL']
    if not validate_config(config, required_keys):
        print("❌ Invalid configuration")
        sys.exit(1)
    
    print('🚀 Starting order data import...\n')
    try:
        fetch_woocommerce_orders(config, website_name)
    except KeyboardInterrupt:
        print("\n⚠️ Process interrupted by user. Progress has been saved.")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()