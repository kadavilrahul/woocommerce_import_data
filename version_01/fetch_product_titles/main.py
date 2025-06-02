import requests
import time
import json
import csv
from reset_script import reset_script

# Load configuration from config.json
try:
    with open('config.json') as f:
        config = json.load(f)
        CONSUMER_KEY = config['CONSUMER_KEY']
        CONSUMER_SECRET = config['CONSUMER_SECRET']
        SITE_URL = config['SITE_URL']
    print('✓ Loaded configuration from config.json')
except FileNotFoundError:
    print("❌ Error: config.json not found. Please create it with your WooCommerce credentials.")
    exit(1)
except json.JSONDecodeError:
    print("❌ Error: config.json is not valid JSON. Please check the format.")
    exit(1)
except KeyError as e:
    print(f"❌ Error: Missing required key {e} in config.json")
    exit(1)

CSV_FILE = "products.csv"
PAGE_PROPERTY_FILE = "current_page.txt"  # File to store the current page number


def get_current_page():
    """Retrieve the current page from the property file."""
    try:
        with open(PAGE_PROPERTY_FILE, "r") as file:
            return int(file.read().strip())
    except FileNotFoundError:
        return 1
    except ValueError:
        print("⚠️ Warning: Invalid page number in current_page.txt. Starting from page 1.")
        return 1


def save_current_page(page):
    """Save the current page number to the property file."""
    try:
        with open(PAGE_PROPERTY_FILE, "w") as file:
            file.write(str(page))
    except IOError as e:
        print(f"⚠️ Warning: Could not save current page: {e}")


def fetch_titles(page):
    """Fetch product titles from WooCommerce API."""
    api_url = f"{SITE_URL}/wp-json/wc/v3/products"
    params = {
        'page': page,
        'per_page': 50,
        'consumer_key': CONSUMER_KEY,
        'consumer_secret': CONSUMER_SECRET
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


def write_titles_to_csv(titles):
    """Write titles to a CSV file."""
    try:
        # Open in append mode to add new titles
        mode = 'a' if get_current_page() > 1 else 'w'
        with open(CSV_FILE, mode, newline='', encoding='utf-8') as f:
            writer = csv.writer(f, quoting=csv.QUOTE_ALL)
            # Write header if it's a new file
            if mode == 'w':
                writer.writerow(['Product Title'])
            # Write titles
            for title in titles:
                writer.writerow([title])
        print(f"✓ Successfully wrote {len(titles)} titles to {CSV_FILE}")
    except Exception as e:
        print(f"❌ Error writing to CSV file: {e}")


def fetch_woocommerce_product_titles():
    """Main function to fetch product titles and save them to CSV."""
    print(f"\n🔄 Starting to fetch product titles from {SITE_URL}")
    current_page = get_current_page()
    total_products = 0

    while True:
        print(f"📥 Fetching page {current_page}...", end=' ', flush=True)
        titles, has_more = fetch_titles(current_page)
        
        if not titles:
            if current_page == 1:
                print("❌ No products found or error occurred.")
                break
            print("✓ No more products to fetch.")
            break

        total_products += len(titles)
        write_titles_to_csv(titles)
        save_current_page(current_page)

        if not has_more:
            print("✓ Reached the last page.")
            break

        current_page += 1
        time.sleep(1)  # Add delay to avoid hitting API rate limits

    print(f"\n✅ Finished! Total products processed: {total_products}")
    print(f"📁 Results saved to {CSV_FILE}")


if __name__ == "__main__":
    print('🚀 Starting product title import...\n')
    try:
        fetch_woocommerce_product_titles()
    except KeyboardInterrupt:
        print("\n⚠️ Process interrupted by user. Progress has been saved.")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
