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

def load_configuration(website_name=None):
    """Load configuration from config.json or environment variables"""
    config = None
    
    # Try to load from config.json first
    if os.path.exists('config.json'):
        try:
            with open('config.json', 'r') as f:
                json_config = json.load(f)
            
            if website_name and website_name in json_config.get('websites', {}):
                config = json_config['websites'][website_name]
                print(f'✓ Loaded configuration for {website_name} from config.json')
            elif 'default_website' in json_config and json_config['default_website'] in json_config.get('websites', {}):
                config = json_config['websites'][json_config['default_website']]
                print(f'✓ Loaded default configuration ({json_config["default_website"]}) from config.json')
            else:
                print('⚠️ Warning: No valid website configuration found in config.json')
        except (json.JSONDecodeError, KeyError) as e:
            print(f'⚠️ Warning: Error reading config.json: {e}')
    
    # Fall back to environment variables if config.json failed
    if not config:
        config = {
            'CONSUMER_KEY': os.getenv('CONSUMER_KEY'),
            'CONSUMER_SECRET': os.getenv('CONSUMER_SECRET'),
            'SITE_URL': os.getenv('SITE_URL'),
            'DOMAIN': os.getenv('DOMAIN_1')
        }
        print('✓ Loaded configuration from environment variables')
    
    # Validate configuration
    required_keys = ['CONSUMER_KEY', 'CONSUMER_SECRET', 'SITE_URL']
    missing_keys = [key for key in required_keys if not config.get(key)]
    if missing_keys:
        print(f"❌ Error: Missing required configuration: {', '.join(missing_keys)}")
        exit(1)
    
    return config

def get_file_paths(website_name="default"):
    """Get file paths for CSV and page tracking based on website name"""
    csv_file = f"data/product_titles_{website_name}.csv"
    page_file = f"data/product_titles_page_{website_name}.txt"
    return csv_file, page_file


def get_current_page(website_name="default"):
    """Retrieve the current page from the property file."""
    _, page_file = get_file_paths(website_name)
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
    _, page_file = get_file_paths(website_name)
    try:
        with open(page_file, "w") as file:
            file.write(str(page))
    except IOError as e:
        print(f"⚠️ Warning: Could not save current page: {e}")


def fetch_titles(page, config):
    """Fetch product titles from WooCommerce API."""
    api_url = f"{config['SITE_URL']}/wp-json/wc/v3/products"
    params = {
        'page': page,
        'per_page': 50,
        'consumer_key': config['CONSUMER_KEY'],
        'consumer_secret': config['CONSUMER_SECRET']
    }
    
    try:
        response = requests.get(api_url, params=params)
        response.raise_for_status()
        products = response.json()
        return [product["name"] for product in products], len(products) == 50
    except requests.RequestException as e:
        print(f"❌ Error fetching data from API: {e}")
        return [], False
    except (KeyError, json.JSONDecodeError) as e:
        print(f"❌ Error processing API response: {e}")
        return [], False


def write_titles_to_csv(titles, website_name="default"):
    """Write titles to a CSV file."""
    csv_file, _ = get_file_paths(website_name)
    try:
        # Ensure data directory exists
        os.makedirs(os.path.dirname(csv_file), exist_ok=True)
        # Open in append mode to add new titles
        mode = 'a' if get_current_page(website_name) > 1 else 'w'
        with open(csv_file, mode, newline='', encoding='utf-8') as f:
            writer = csv.writer(f, quoting=csv.QUOTE_ALL)
            # Write header if it's a new file
            if mode == 'w':
                writer.writerow(['Product Title'])
            # Write titles
            for title in titles:
                writer.writerow([title])
        print(f"✓ Successfully wrote {len(titles)} titles to {csv_file}")
    except Exception as e:
        print(f"❌ Error writing to CSV file: {e}")


def fetch_woocommerce_product_titles(config, website_name="default"):
    """Main function to fetch product titles and save them to CSV."""
    csv_file, _ = get_file_paths(website_name)
    print(f"\n🔄 Starting to fetch product titles from {config['SITE_URL']}")
    if website_name != "default":
        print(f"📊 Website: {website_name}")
    
    current_page = get_current_page(website_name)
    total_products = 0

    while True:
        print(f"📥 Fetching page {current_page}...", end=' ', flush=True)
        titles, has_more = fetch_titles(current_page, config)
        
        if not titles:
            if current_page == 1:
                print("❌ No products found or error occurred.")
                break
            print("✓ No more products to fetch.")
            break

        total_products += len(titles)
        write_titles_to_csv(titles, website_name)
        save_current_page(current_page, website_name)

        if not has_more:
            print("✓ Reached the last page.")
            break

        current_page += 1
        time.sleep(1)  # Add delay to avoid hitting API rate limits

    print(f"\n✅ Finished! Total products processed: {total_products}")
    print(f"📁 Results saved to {csv_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Fetch WooCommerce product titles with multi-website support')
    parser.add_argument('--website', type=str, help='Website name (from config.json)')
    
    args = parser.parse_args()
    
    print('🚀 Starting product title import...\n')
    try:
        config = load_configuration(args.website)
        fetch_woocommerce_product_titles(config, args.website or "default")
    except KeyboardInterrupt:
        print("\n⚠️ Process interrupted by user. Progress has been saved.")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
