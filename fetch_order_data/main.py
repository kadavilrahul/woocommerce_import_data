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

CSV_FILE = "order_data.csv"
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


def fetch_orders(page):
    """Fetch order data from WooCommerce API."""
    api_url = f"{SITE_URL}/wp-json/wc/v3/orders"
    params = {
        'page': page,
        'per_page': 50,
        'consumer_key': CONSUMER_KEY,
        'consumer_secret': CONSUMER_SECRET
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


def write_orders_to_csv(orders):
    """Write order data to a CSV file."""
    try:
        # Open in append mode to add new orders
        mode = 'a' if get_current_page() > 1 else 'w'
        with open(CSV_FILE, mode, newline='', encoding='utf-8') as f:
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
        print(f"✓ Successfully wrote {len(orders)} orders to {CSV_FILE}")
    except Exception as e:
        print(f"❌ Error writing to CSV file: {e}")


def fetch_woocommerce_orders():
    """Main function to fetch order data and save them to CSV."""
    print(f"\n🔄 Starting to fetch order data from {SITE_URL}")
    current_page = get_current_page()
    total_orders = 0

    while True:
        print(f"📥 Fetching page {current_page}...", end=' ', flush=True)
        orders, has_more = fetch_orders(current_page)
        
        if not orders:
            if current_page == 1:
                print("❌ No orders found or error occurred.")
                break
            print("✓ No more orders to fetch.")
            break

        total_orders += len(orders)
        write_orders_to_csv(orders)
        save_current_page(current_page)

        if not has_more:
            print("✓ Reached the last page.")
            break

        current_page += 1
        time.sleep(1)  # Add delay to avoid hitting API rate limits

    print(f"\n✅ Finished! Total orders processed: {total_orders}")
    print(f"📁 Results saved to {CSV_FILE}")


if __name__ == "__main__":
    print('🚀 Starting order data import...\n')
    try:
        fetch_woocommerce_orders()
    except KeyboardInterrupt:
        print("\n⚠️ Process interrupted by user. Progress has been saved.")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")