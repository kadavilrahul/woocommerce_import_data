import requests
import time
import openpyxl
from reset_script import reset_script

CONSUMER_KEY = "ck_8e6c79d7691c17d67b0b0aff67bc257752c54abb"
CONSUMER_SECRET = "cs_9ee336566af22fcbe3034b2e4354572a9d6a4836"
SITE_URL = "https://nilgiristores.in"
EXCEL_FILE = "products.xlsx"
PAGE_PROPERTY_FILE = "current_page.txt"  # File to store the current page number


def get_current_page():
    """Retrieve the current page from the property file."""
    try:
        with open(PAGE_PROPERTY_FILE, "r") as file:
            return int(file.read().strip())
    except FileNotFoundError:
        return 1


def save_current_page(page):
    """Save the current page number to the property file."""
    with open(PAGE_PROPERTY_FILE, "w") as file:
        file.write(str(page))


def fetch_titles(page):
    """Fetch product titles from WooCommerce API."""
    api_url = f"{SITE_URL}/wp-json/wc/v3/products?page={page}&per_page=50&consumer_key={CONSUMER_KEY}&consumer_secret={CONSUMER_SECRET}"
    response = requests.get(api_url)
    if response.status_code != 200:
        return [], False  # Return an empty list and indicate an error
    products = response.json()
    return [product["name"] for product in products], len(products) == 50


def write_titles_to_excel(titles):
    """Write titles to an Excel file."""
    try:
        wb = openpyxl.load_workbook(EXCEL_FILE)
    except FileNotFoundError:
        wb = openpyxl.Workbook()

    sheet = wb.active
    last_row = sheet.max_row
    for idx, title in enumerate(titles, start=last_row + 1):
        sheet.cell(row=idx, column=1, value=title)

    wb.save(EXCEL_FILE)


def fetch_woocommerce_product_titles():
    """Main function to fetch product titles and save them to Excel."""
    current_page = get_current_page()
    while True:
        titles, has_more = fetch_titles(current_page)
        if not titles:
            break  # Exit if no titles were fetched or an error occurred

        write_titles_to_excel(titles)
        print(f"Page {current_page}: Imported {len(titles)} product titles.")
        save_current_page(current_page)

        if not has_more:
            print("All products have been fetched and listed in the Excel file.")
            break

        current_page += 1
        time.sleep(1 * 15)  # Wait for 1 minutes


if __name__ == "__main__":
    fetch_woocommerce_product_titles()
